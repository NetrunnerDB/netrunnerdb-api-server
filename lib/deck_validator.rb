# frozen_string_literal: true

# Validates Decks against provided validation requests.
class DeckValidator # rubocop:disable Metrics/ClassLength
  attr_reader :valid, :validations, :errors

  # TODO: make error codes with maps for messages to aid translation and testing.
  def initialize(deck)
    @deck = deck.deep_dup
    # Force all keys to lowercase, which includes card ids from the cards object.
    @deck.deep_transform_keys!(&:downcase)
    # Force values for fields specifying IDs to lowercase.
    %w[identity_card_id side_id].each do |k|
      @deck[k].downcase! if @deck.key?(k)
    end

    @validation_performed = false

    @valid = false
    # Errors accumulated through the validation process.
    @errors = []
    # All valid cards specified in the deck.
    @cards = {}
    # All valid formats specified in validations.
    @formats = {}
    # All valid card pools specified in validations.
    @card_pools = {}
    # All valid restrictions specified in validations.
    @restrictions = {}
    # Map of restriction id to UnifiedRestrictions for affected cards.
    @unified_restrictions = {}
    # Identity card object
    @identity = nil
    # Basic rules influence spent.  If -1, this has not been calculated yet.
    @basic_influence_spent = -1
    # All valid snapshots specified in validations.
    @snapshots = {}
    # All requested validations, used to keep specific errors tied to the validations requested.
    @validations = []
    # Card ids keyed by card pool specified in the deck
    @card_pools_to_card_ids = {}
    # Alliance cards with faction restrictions.
    @alliance_cards = {
      'consulting_visit' => 'weyland_consortium',
      'executive_search_firm' => 'weyland_consortium',
      'heritage_committee' => 'jinteki',
      'raman_rai' => 'jinteki',
      'ibrahim_salem' => 'nbn',
      'salems_hospitality' => 'nbn',
      'jeeves_model_bioroids' => 'haas_bioroid',
      'product_recall' => 'haas_bioroid'
    }

    if @deck.key?('validations')
      @deck['validations'].each do |v|
        @validations << DeckValidation.new(v)
      end
    end

    @validation_errors = false
  end

  # rubocop:disable Metrics/BlockNesting
  def valid? # rubocop:disable Metrics/MethodLength
    unless @validation_performed
      @validation_performed = true
      if all_required_fields_present?
        load_cards_from_deck
        load_formats_from_deck
        load_card_pools_from_deck
        load_cards_from_card_pools
        load_restrictions_from_deck
        load_snapshots_from_deck
        if all_ids_exist?
          @validations.each do |v| # rubocop:disable Metrics/BlockLength
            if v.basic_deckbuilding_rules
              check_basic_deckbuilding_rules.each do |e|
                v.add_error(e)
                @validation_errors = true
              end
            end

            # Validate against Card Pool
            unless v.card_pool_id.nil?
              check_cards_in_card_pool(v).each do |e|
                v.add_error(e)
                @validation_errors = true
              end
            end

            # Validate against Restriction
            next if v.restriction_id.nil?

            r = @unified_restrictions[v.restriction_id]
            Rails.logger.error "Restriction is #{r.inspect}"

            # Check for banned cards.
            ([@deck['identity_card_id']] + @deck['cards'].keys).each do |card_id|
              next unless r.key?(card_id) && r[card_id].is_banned

              v.add_error(format('Card `%<card_id>s` is banned in restriction `%<restriction_id>s`.',
                                 card_id:, restriction_id: v.restriction_id))
              @validation_errors = true
            end

            # Check for # of restricted cards.
            restricted_cards_in_deck = []
            ([@deck['identity_card_id']] + @deck['cards'].keys).each do |card_id|
              restricted_cards_in_deck << card_id if r.key?(card_id) && r[card_id].is_restricted
            end
            if restricted_cards_in_deck.size > 1 # rubocop:disable Metrics/BlockNesting
              v.add_error(
                format('Deck has too many cards marked restricted in restriction `%<restriction_id>s`: %<card_ids>s.',
                       restriction_id: v.restriction_id,
                       card_ids: restricted_cards_in_deck.join(', '))
              )
              @validation_errors = true
            end

            # Sum eternal points.
            eternal_points = 0
            cards_with_points = []
            ([@deck['identity_card_id']] + @deck['cards'].keys).each do |card_id|
              next unless r.key?(card_id) && r[card_id].eternal_points.positive?

              cards_with_points << format(
                '%<card_id>s (%<points>d)', card_id:, points: r[card_id].eternal_points
              )
              eternal_points += r[card_id].eternal_points
            end
            if eternal_points > 7
              v.add_error(
                format(
                  'Deck has too many points (%<points>d) for eternal restriction `%<restriction_id>s`: %<cards_with_points>s.', # rubocop:disable Layout/LineLength
                  points: eternal_points,
                  restriction_id: v.restriction_id, cards_with_points: cards_with_points.join(', ')
                )
              )
              @validation_errors = true
            end

            # Check for universal faction cost.
            # Each copy of a card with a universal faction cost has
            # the universal faction cost added to its influence cost.
            universal_faction_cost = 0
            cards_with_universal_faction_cost = []
            @deck['cards'].each do |card_id, qty|
              next unless r.key?(card_id) && r[card_id].universal_faction_cost.positive?

              universal_faction_cost += (qty * r[card_id].universal_faction_cost)
              cards_with_universal_faction_cost << format(
                '%<card_id>s (%<cost>d)',
                card_id:,
                cost: qty * r[card_id].universal_faction_cost
              )
            end
            if universal_faction_cost.positive? &&
               !@identity.influence_limit.nil? &&
               ((@basic_influence_spent + universal_faction_cost) > @identity.influence_limit)
              v.add_error(
                format(
                  'Influence limit for %<identity>s is %<influence_limit>d, but after Universal Influence applied from restriction `%<restriction_id>s`, deck has spent %<influence_spent>d influence from %<cards_with_influence>s.', # rubocop:disable Layout/LineLength
                  identity: @identity.title,
                  influence_limit: @identity.influence_limit,
                  restriction_id: v.restriction_id,
                  influence_spent: (@basic_influence_spent + universal_faction_cost),
                  cards_with_influence: cards_with_universal_faction_cost.join(', ')
                )
              )
              @validation_errors = true
            end

            # Check for global penalty.
            # Each copy of a card with a global penalty reduces your identity influence by 1, to a minimum of 1.
            global_penalty = 0
            cards_with_global_penalty = []
            @deck['cards'].each do |card_id, qty|
              if r.key?(card_id) && r[card_id].has_global_penalty
                global_penalty += qty
                cards_with_global_penalty << "#{card_id} (#{qty})"
              end
            end
            next unless global_penalty.positive? && !@identity.influence_limit.nil?

            influence_limit = [(@identity.influence_limit - global_penalty), 1].max
            next unless @basic_influence_spent > influence_limit

            v.add_error(
              format(
                'Influence limit for %<identity>s is %<influence_limit>d after Global Penalty applied from restriction `%<restriction_id>s`, but deck has spent %<global_penalty>d influence from %<cards_with_global_penalty>s.', # rubocop:disable Layout/LineLength
                identity: @identity.title,
                influence_limit:,
                restriction_id: v.restriction_id,
                global_penalty:,
                cards_with_global_penalty: cards_with_global_penalty.join(', ')
              )
            )
            @validation_errors = true
          end
        end
      end
    end

    (@errors.empty? and !@validation_errors)
  end
  # rubocop:enable Metrics/BlockNesting

  private

  def all_required_fields_present?
    # Deck must have identity_card_id specified.
    @errors << 'Deck is missing `identity_card_id` field.' unless @deck.key?('identity_card_id')

    # Deck must have side_id specified.
    @errors << 'Deck is missing `side_id` field.' unless @deck.key?('side_id')

    # Deck must have a cards array with at least 1 card.
    @errors << 'Deck must specify some cards.' if !@deck.key?('cards') || (@deck.key?('cards') && @deck['cards'].empty?)

    # A list of validations must be present with at least 1 item.
    @errors << 'Validation request must specify at least one validation to perform.' if @validations.empty?

    @errors.empty?
  end

  def load_cards_from_deck
    # Populate @cards by retrieving cards specified in the deck.
    Card.where(id: [@deck['identity_card_id']] + @deck['cards'].keys).find_each { |c| @cards[c.id] = c }
  end

  def load_formats_from_deck
    format_ids = []
    @validations.each do |v|
      format_ids << v.format_id unless v.format_id.nil?
    end
    Format.where(id: format_ids).find_each { |f| @formats[f.id] = f }
  end

  def load_card_pools_from_deck
    card_pool_ids = []
    @validations.each do |v|
      card_pool_ids << v.card_pool_id unless v.card_pool_id.nil?
    end
    CardPool.where(id: card_pool_ids).find_each { |p| @card_pools[p.id] = p }
  end

  def load_cards_from_card_pools
    @card_pools.each_key do |p|
      @card_pools_to_card_ids[p] = Set.new
      CardPool.find(p).card_ids.each do |c|
        @card_pools_to_card_ids[p].add(c)
      end
    end
  end

  def load_restrictions_from_deck
    restriction_ids = []
    @validations.each do |v|
      restriction_ids << v.restriction_id unless v.restriction_id.nil?
    end
    Restriction.where(id: restriction_ids).find_each do |r|
      @restrictions[r.id] = r
      @unified_restrictions[r.id] = {}
      UnifiedRestriction.cards_restricted_by(r.id).each { |c| @unified_restrictions[r.id][c.card_id] = c }
    end
  end

  def load_snapshots_from_deck
    snapshot_ids = []
    @validations.each do |v|
      snapshot_ids << v.snapshot_id unless v.snapshot_id.nil?
    end
    Snapshot.where(id: snapshot_ids).find_each { |f| @snapshots[f.id] = f }
  end

  def all_ids_exist?
    # identity_card_id is valid
    unless @cards.key?(@deck['identity_card_id'])
      @errors << "`identity_card_id` `#{@deck['identity_card_id']}` does not exist."
    end

    # side_id is valid
    @errors << "`side_id` `#{@deck['side_id']}` does not exist." unless %w[corp runner].include?(@deck['side_id'])

    @deck['cards'].each_key do |card_id|
      @errors << "Card `#{card_id}` does not exist." unless @cards.key?(card_id.to_s)
    end

    # Check all format, snapshot, card pool, restriction id values as well.
    @validations.each do |v|
      @errors << "Format `#{v.format_id}` does not exist." if !v.format_id.nil? && !@formats.key?(v.format_id)
      if !v.card_pool_id.nil? && !@card_pools.key?(v.card_pool_id)
        @errors << "Card Pool `#{v.card_pool_id}` does not exist."
      end
      if !v.restriction_id.nil? && !@restrictions.key?(v.restriction_id)
        @errors << "Restriction `#{v.restriction_id}` does not exist."
      end
      next if v.snapshot_id.nil?

      @errors << "Snapshot `#{v.snapshot_id}` does not exist." unless @snapshots.key?(v.snapshot_id)
    end

    @errors.empty?
  end

  def check_basic_deckbuilding_rules
    local_errors = []
    # identity_card_id side matches deck side
    if @cards[@deck['identity_card_id']].side_id != @deck['side_id']
      local_errors << format(
        'Identity `%<identity>s` has side `%<side_id>s` which does not match given side `%<given_side>s`',
        identity: @deck['identity_card_id'],
        side_id: @cards[@deck['identity_card_id']].side_id,
        given_side: @deck['side_id']
      )
    end

    # Ensure that all card ids exist and match the side of the identity.
    @deck['cards'].each_key do |card_id|
      if @deck['side_id'] != @cards[card_id.to_s].side_id
        local_errors << format(
          'Card `%<card_id>s` side `%<card_side>s` does not match deck side `%<deck_side>s`',
          card_id:,
          card_side: @cards[card_id.to_s].side_id,
          deck_side: @deck['side_id']
        )
      end

      # Identity cards may not be included as cards in decks.
      if %w[corp_identity runner_identity].include?(@cards[card_id].card_type_id)
        local_errors << "Decks may not include multiple identities.  Identity card `#{card_id}` is not allowed."
      end
    end

    @identity = @cards[@deck['identity_card_id']]

    # Check deck size minimums
    num_cards = @deck['cards'].map { |_slot, quantity| quantity }.sum
    if num_cards < @identity.minimum_deck_size
      local_errors << format('Minimum deck size is %<min_size>d, but deck has %<num_cards>d cards.',
                             min_size: @identity.minimum_deck_size, num_cards:)
    end

    # Check cards against deck limits.
    @deck['cards'].each do |card_id, quantity|
      limit = if %w[ampere_cybernetics_for_anyone
                    nova_initiumia_catalyst_impetus].include?(@identity.id)
                1
              else
                @cards[card_id.to_s].deck_limit
              end
      next unless quantity > limit

      local_errors << format(
        'Card `%<card_id>s` has a deck limit of %<limit>d, but %<copies>d copies are included.',
        card_id:,
        limit:,
        copies: quantity
      )
    end

    # Check Corp decks for deck-size based agenda points restrictions.
    if @deck['side_id'] == 'corp'
      agenda_points = @cards.select do |card_id|
                        @cards[card_id].card_type_id == 'agenda'
                      end.map { |card_id, card| card.agenda_points * @deck['cards'][card_id] }.sum # rubocop:disable Style/MultilineBlockChain

      min_agenda_points =
        (num_cards < @identity.minimum_deck_size ? @identity.minimum_deck_size : num_cards) / 5 * 2 + 2
      required_agenda_points = [min_agenda_points, min_agenda_points + 1]
      unless required_agenda_points.include?(agenda_points)
        local_errors << format(
          'Deck with size %<deck_size>d requires %<required_points>s agenda points, but deck only has %<points>d',
          deck_size: num_cards,
          required_points: required_agenda_points.to_json,
          points: agenda_points
        )
      end
    end

    # Check agenda faction restrictions.
    if @identity.id == 'ampere_cybernetics_for_anyone'
      # Ampere may only have 2 agendas per non-neutral faction.
      faction_agenda_count = {}
      @cards.select do |card_id|
        @cards[card_id].card_type_id == 'agenda' and @cards[card_id].faction_id != 'neutral_corp'
      end.each_value do |card| # rubocop:disable Style/MultilineBlockChain
        faction_agenda_count[card.faction_id] = 0 unless faction_agenda_count.key?(card.faction_id)
        faction_agenda_count[card.faction_id] += 1
      end
      faction_agenda_count.each do |faction_id, count|
        if count > 2
          local_errors << "Ampere decks may not include more than 2 agendas per non-neutral faction. There are #{count} `#{faction_id}` agendas present." # rubocop:disable Layout/LineLength
        end
      end
    else
      @deck['cards']
        .select do |card_id|
        @cards[card_id].card_type_id == 'agenda' and ![@identity.faction_id,
                                                       'neutral_corp'].include?(@cards[card_id].faction_id)
      end # rubocop:disable Style/MultilineBlockChain
        .each_key do |card_id|
        local_errors << "Agenda `#{card_id}` with faction_id `#{@cards[card_id].faction_id}` is not allowed in a `#{@identity.faction_id}` deck." # rubocop:disable Layout/LineLength
      end
    end

    # Check influence
    unless @identity.influence_limit.nil?
      basic_calculate_influence_spent

      if @basic_influence_spent > @identity.influence_limit
        local_errors << format(
          'Influence limit for %<identity>s is %<influence_limit>d, but deck has spent %<influence_spent>d influence',
          identity: @identity.title,
          influence_limit: @identity.influence_limit,
          influence_spent: @basic_influence_spent
        )
      end
    end

    local_errors
  end

  def num_cards_by_type(card_type)
    @deck['cards'].map { |slot, quantity| @cards[slot].card_type_id == card_type ? quantity : 0 }.sum
  end

  def num_non_alliance_cards_for(faction)
    @deck['cards'].map do |card_id, quantity|
      (@cards[card_id].faction_id == faction) && !@alliance_cards.key?(card_id) ? quantity : 0
    end.sum
  end

  def influence_for(card_id)
    @deck['cards'][card_id] * @cards[card_id].influence_cost
  end

  def basic_calculate_influence_spent
    return unless @basic_influence_spent == -1

    influence_spent =
      @cards.select do |card_id|
        @cards[card_id].faction_id != @identity.faction_id and (
          @cards[card_id].influence_cost.nil? ? false : @cards[card_id].influence_cost.positive?
        )
      end # rubocop:disable Style/MultilineBlockChain
      .map { |card_id, card| card.influence_cost * @deck['cards'][card_id] }.sum
    # The Professor ignores the influence cost for the 1st copy of each program in the deck,
    # so subtract that much influence.
    if @identity.id == 'the_professor_keeper_of_knowledge'
      first_program_influence_spent =
        @cards.select do |card_id|
          @cards[card_id].faction_id != @identity.faction_id and @cards[card_id].card_type_id == 'program' and (
            @cards[card_id].influence_cost.nil? ? false : @cards[card_id].influence_cost.positive?
          )
        end # rubocop:disable Style/MultilineBlockChain
        .map { |_card_id, card| card.influence_cost }.sum
      influence_spent -= first_program_influence_spent
    end

    # Handle alliance cards
    if @deck['cards'].key?('mumba_temple') && (num_cards_by_type('ice') >= 15)
      influence_spent -= influence_for('mumba_temple')
    end

    if @deck['cards'].key?('mumbad_virtual_tour') && (num_cards_by_type('asset') >= 7)
      influence_spent -= influence_for('mumbad_virtual_tour')
    end

    num_cards = @deck['cards'].map { |_slot, quantity| quantity }.sum
    if @deck['cards'].key?('museum_of_history') && (num_cards >= 50)
      influence_spent -= influence_for('museum_of_history')
    end

    if @deck['cards'].key?('pad_factory') && (@deck['cards']['pad_campaign'] == 3)
      influence_spent -= influence_for('pad_factory')
    end

    # Check faction-locked alliance cards.
    @deck['cards'].each_key do |card_id|
      next unless @alliance_cards.key?(card_id) && (@cards[card_id].faction_id != @identity.faction_id)

      num_non_alliance_for_faction = num_non_alliance_cards_for(@cards[card_id].faction_id)
      influence_spent -= influence_for(card_id) if num_non_alliance_for_faction >= 6
    end
    @basic_influence_spent = influence_spent
  end

  def check_cards_in_card_pool(validation)
    local_errors = []
    return local_errors if validation.card_pool_id.nil?

    @deck['cards'].each_key do |c|
      next if @card_pools_to_card_ids[validation.card_pool_id].include?(c)

      local_errors << format(
        'Card `%<card_id>s` is not present in Card Pool `%<card_pool_id>s`.',
        card_id: c,
        card_pool_id: validation.card_pool_id
      )
    end
    local_errors
  end
end

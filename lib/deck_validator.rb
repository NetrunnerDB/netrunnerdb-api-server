class DeckValidator

  attr_reader :valid
  attr_reader :validations
  attr_reader :errors

  # TODO: make error codes with maps for messages to aid translation and testing.
  def initialize(deck)
    @deck = deck.deep_dup
    # Force all keys to lowercase, which includes card ids from the cards object.
    @deck.deep_transform_keys!(&:downcase)
    # Force values for fields specifying IDs to lowercase.
    ['identity_card_id', 'side_id'].each do |k|
      if @deck.has_key?(k)
        @deck[k].downcase!
      end
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
      'product_recall' => 'haas_bioroid',
    }

    if @deck.has_key?('validations')
      @deck['validations'].each do |v|
        @validations << DeckValidation.new(v)
      end
    end

    @validation_errors = false
  end

  def is_valid?
    if not @validation_performed
      @validation_performed = true
      if all_required_fields_present?
        load_cards_from_deck
        load_formats_from_deck
        load_card_pools_from_deck
        load_cards_from_card_pools
        load_restrictions_from_deck
        load_snapshots_from_deck
        if all_ids_exist?
          @validations.each do |v|
            if v.basic_deckbuilding_rules
              check_basic_deckbuilding_rules.each do |e|
                v.add_error(e)
                @validation_errors = true
              end
            end

            # Validate against Card Pool
            if !v.card_pool_id.nil?
              check_cards_in_card_pool(v).each do |e|
                v.add_error(e)
                @validation_errors = true
              end
            end

            # Validate against Restriction
            if !v.restriction_id.nil?
              r = @unified_restrictions[v.restriction_id]
              Rails.logger.error 'Restriction is %s' % r.inspect

              # Check for banned cards.
              ([@deck['identity_card_id']] + @deck['cards'].keys).each do |card_id|
                if r.has_key?(card_id) and r[card_id].is_banned
                  v.add_error('Card `%s` is banned in restriction `%s`.' % [card_id, v.restriction_id])
                  @validation_errors = true
                end
              end

              # Check for # of restricted cards.
              restricted_cards_in_deck = []
              ([@deck['identity_card_id']] + @deck['cards'].keys).each do |card_id|
                if r.has_key?(card_id) and r[card_id].is_restricted
                  restricted_cards_in_deck << card_id
                end
              end
              if restricted_cards_in_deck.size > 1
                v.add_error('Deck has too many cards marked restricted in restriction `%s`: %s.' % [v.restriction_id, restricted_cards_in_deck.join(', ')])
                @validation_errors = true
              end

              # Sum eternal points.
              eternal_points = 0
              cards_with_points = []
              ([@deck['identity_card_id']] + @deck['cards'].keys).each do |card_id|
                if r.has_key?(card_id) and r[card_id].eternal_points > 0
                  cards_with_points << '%s (%d)' % [card_id, r[card_id].eternal_points]
                  eternal_points += r[card_id].eternal_points
                end
              end
              if eternal_points > 7
                v.add_error('Deck has too many points (%d) for eternal restriction `%s`: %s.' % [eternal_points, v.restriction_id, cards_with_points.join(', ')])
                @validation_errors = true
              end

              # Check for universal faction cost.
              # Each copy of a card with a universal faction cost has the universal faction cost added to its influence cost.
              universal_faction_cost = 0
              cards_with_universal_faction_cost = []
              @deck['cards'].each do |card_id, qty|
                if r.has_key?(card_id) and r[card_id].universal_faction_cost > 0
                  universal_faction_cost += (qty * r[card_id].universal_faction_cost)
                  cards_with_universal_faction_cost << '%s (%d)' % [card_id, qty * r[card_id].universal_faction_cost]
                end
              end
              if universal_faction_cost > 0 and !@identity.influence_limit.nil? and (@basic_influence_spent + universal_faction_cost) > @identity.influence_limit
                v.add_error('Influence limit for %s is %d, but after Universal Influence applied from restriction `%s`, deck has spent %d influence from %s.' % [@identity.title, @identity.influence_limit, v.restriction_id, (@basic_influence_spent + universal_faction_cost), cards_with_universal_faction_cost.join(', ')])
                @validation_errors = true
              end

              # Check for global penalty.
              # Each copy of a card with a global penalty reduces your identity influence by 1, to a minimum of 1.
              global_penalty = 0
              cards_with_global_penalty = []
              @deck['cards'].each do |card_id, qty|
                if r.has_key?(card_id) and r[card_id].has_global_penalty
                  global_penalty += qty
                  cards_with_global_penalty << '%s (%d)' % [card_id, qty]
                end
              end
              if global_penalty > 0 and !@identity.influence_limit.nil?
                influence_limit = [(@identity.influence_limit - global_penalty), 1].max
                if @basic_influence_spent > influence_limit
                  v.add_error('Influence limit for %s is %d after Global Penalty applied from restriction `%s`, but deck has spent %d influence from %s.' % [@identity.title, influence_limit, v.restriction_id, @basic_influence_spent, cards_with_global_penalty.join(', ')])
                @validation_errors = true
                end
              end
            end
          end
        end
      end
    end

    return (@errors.size == 0 and !@validation_errors)
  end

  private

  def all_required_fields_present?
    # Deck must have identity_card_id specified.
    if not @deck.has_key?('identity_card_id')
      @errors << "Deck is missing `identity_card_id` field."
    end

    # Deck must have side_id specified.
    if not @deck.has_key?('side_id')
      @errors << "Deck is missing `side_id` field."
    end

    # Deck must have a cards array with at least 1 card.
    if not @deck.has_key?('cards') or (@deck.has_key?('cards') and @deck['cards'].size == 0)
      @errors << "Deck must specify some cards."
    end

    # A list of validations must be present with at least 1 item.
    if @validations.size == 0
      @errors << "Validation request must specify at least one validation to perform."
    end

    return @errors.size == 0
  end

  def load_cards_from_deck
    # Populate @cards by retrieving cards specified in the deck.
    Card.where(id: [@deck['identity_card_id']] + @deck['cards'].keys).each {|c| @cards[c.id] = c}
  end

  def load_formats_from_deck
    format_ids = []
    @validations.each do |v|
      if !v.format_id.nil?
        format_ids << v.format_id
      end
    end
    Format.where(id: format_ids).each {|f| @formats[f.id] = f}
  end

  def load_card_pools_from_deck
    card_pool_ids = []
    @validations.each do |v|
      if !v.card_pool_id.nil?
        card_pool_ids << v.card_pool_id
      end
    end
    CardPool.where(id: card_pool_ids).each {|p| @card_pools[p.id] = p}
  end

  def load_cards_from_card_pools
    @card_pools.keys.each do |p|
      Rails.logger.info 'Card pool id is %s' % p
      @card_pools_to_card_ids[p] = Set.new
      CardPool.find(p).card_ids.each do |c|
        @card_pools_to_card_ids[p].add(c)
      end
    end
  end

  def load_restrictions_from_deck
    restriction_ids = []
    @validations.each do |v|
      if !v.restriction_id.nil?
        restriction_ids << v.restriction_id
      end
    end
    Restriction.where(id: restriction_ids).each do |r|
      @restrictions[r.id] = r
      @unified_restrictions[r.id] = {}
      UnifiedRestriction.cards_restricted_by(r.id).each {|c| @unified_restrictions[r.id][c.card_id] = c}
    end
  end

  def load_snapshots_from_deck
    snapshot_ids = []
    @validations.each do |v|
      if !v.snapshot_id.nil?
        snapshot_ids << v.snapshot_id
      end
    end
    Snapshot.where(id: snapshot_ids).each {|f| @snapshots[f.id] = f}
  end

  def all_ids_exist?
    # identity_card_id is valid
    if not @cards.has_key?(@deck['identity_card_id'])
      @errors << '`identity_card_id` `%s` does not exist.' % @deck['identity_card_id']
    end

    # TODO: basic deckbuilding should verify that none of the included cards are ids.

    # side_id is valid
    if not ['corp', 'runner'].include?(@deck['side_id'])
      @errors << '`side_id` `%s` does not exist.' % @deck['side_id']
    end

    @deck['cards'].each do |card_id, quantity|
      if !@cards.has_key?(card_id.to_s)
        @errors << 'Card `%s` does not exist.' % card_id
      end
    end

    # Check all format, snapshot, card pool, restriction id values as well.
    @validations.each do |v|
      if !v.format_id.nil?
        if !@formats.has_key?(v.format_id)
          @errors << 'Format `%s` does not exist.' % v.format_id
        end
      end
      if !v.card_pool_id.nil?
        if !@card_pools.has_key?(v.card_pool_id)
          @errors << 'Card Pool `%s` does not exist.' % v.card_pool_id
        end
      end
      if !v.restriction_id.nil?
        if !@restrictions.has_key?(v.restriction_id)
          @errors << 'Restriction `%s` does not exist.' % v.restriction_id
        end
      end
      if !v.snapshot_id.nil?
        if !@snapshots.has_key?(v.snapshot_id)
          @errors << 'Snapshot `%s` does not exist.' % v.snapshot_id
        end
      end
    end

    return @errors.size == 0
  end

  def check_basic_deckbuilding_rules
    local_errors = []
    # identity_card_id side matches deck side
    if @cards[@deck['identity_card_id']].side_id != @deck['side_id']
      local_errors << 'Identity `%s` has side `%s` which does not match given side `%s`' % [@deck['identity_card_id'], @cards[@deck['identity_card_id']].side_id, @deck['side_id']]
    end

    # Ensure that all card ids exist and match the side of the identity.
    @deck['cards'].each do |card_id, quantity|
      if @deck['side_id'] != @cards[card_id.to_s].side_id
        local_errors << 'Card `%s` side `%s` does not match deck side `%s`' % [card_id, @cards[card_id.to_s].side_id, @deck['side_id']]
      end
    end

    @identity = @cards[@deck['identity_card_id']]

    # Check deck size minimums
    num_cards = @deck['cards'].map{ |slot, quantity| quantity }.sum
    if num_cards < @identity.minimum_deck_size
      local_errors << "Minimum deck size is %d, but deck has %d cards." % [@identity.minimum_deck_size, num_cards]
    end

    # Check cards against deck limits.
    @deck['cards'].each do |card_id, quantity|
      limit = ['ampere_cybernetics_for_anyone', 'nova_initiumia_catalyst_impetus'].include?(@identity.id) ? 1 : @cards[card_id.to_s].deck_limit
      if quantity > limit
        local_errors << 'Card `%s` has a deck limit of %d, but %d copies are included.' % [card_id, limit, quantity]
      end
    end

    # Check Corp decks for deck-size based agenda points restrictions.
    if @deck['side_id'] == 'corp'
      agenda_points = @cards.select {|card_id| @cards[card_id].card_type_id == 'agenda'}.map{|card_id, card| card.agenda_points * @deck['cards'][card_id] }.sum

      min_agenda_points = (num_cards < @identity.minimum_deck_size ? @identity.minimum_deck_size : num_cards) / 5 * 2 + 2
      required_agenda_points = [min_agenda_points, min_agenda_points + 1]
      if not required_agenda_points.include?(agenda_points)
        local_errors << "Deck with size %d requires %s agenda points, but deck only has %d" % [num_cards, required_agenda_points.to_json, agenda_points]
      end
    end

    # Check agenda faction restrictions.
    if @identity.id == 'ampere_cybernetics_for_anyone'
      # Ampere may only have 2 agendas per non-neutral faction.
      faction_agenda_count = {}
      @cards.select{|card_id| @cards[card_id].card_type_id == 'agenda' and @cards[card_id].faction_id != 'neutral_corp'}.each do |card_id, card|
        if not faction_agenda_count.has_key?(card.faction_id)
          faction_agenda_count[card.faction_id] = 0
        end
        faction_agenda_count[card.faction_id] += 1
      end
      faction_agenda_count.each do |faction_id, count|
        if count > 2
          local_errors << "Ampere decks may not include more than 2 agendas per non-neutral faction. There are #{count} `#{faction_id}` agendas present."
        end
      end
    else
      @deck['cards']
        .select{|card_id| @cards[card_id].card_type_id == 'agenda' and not [@identity.faction_id, 'neutral_corp'].include?(@cards[card_id].faction_id)}
        .each do |card_id, card|
          local_errors << "Agenda `#{card_id}` with faction_id `#{@cards[card_id].faction_id}` is not allowed in a `#{@identity.faction_id}` deck."
      end
    end

    # Check influence
    if not @identity.influence_limit.nil?
      basic_calculate_influence_spent

      if @basic_influence_spent > @identity.influence_limit
        local_errors << "Influence limit for %s is %d, but deck has spent %d influence" % [@identity.title, @identity.influence_limit, @basic_influence_spent]
      end
    end

    return local_errors
  end

  def num_cards_by_type(card_type)
    @deck['cards'].map{ |slot, quantity| @cards[slot].card_type_id == card_type ? quantity : 0 }.sum
  end

  def num_non_alliance_cards_for(faction)
    @deck['cards'].map{ |card_id, quantity| (@cards[card_id].faction_id == faction and !@alliance_cards.has_key?(card_id)) ? quantity : 0 }.sum
  end

  # TODO: Handle alliance cards: https://netrunnerdb.com/find/?q=x%3Ainfluence&sort=name&view=text&_locale=en
  def basic_calculate_influence_spent
    if @basic_influence_spent == -1
      influence_spent = @cards.select{|card_id| @cards[card_id].faction_id != @identity.faction_id and (@cards[card_id].influence_cost.nil? ? false : @cards[card_id].influence_cost > 0)}
        .map{|card_id, card| card.influence_cost * @deck['cards'][card_id] }.sum
      # The Professor ignores the influence cost for the 1st copy of each program in the deck, so subtract that much influence.
      if @identity.id == 'the_professor_keeper_of_knowledge'
        first_program_influence_spent = @cards.select{|card_id| @cards[card_id].faction_id != @identity.faction_id and (@cards[card_id].influence_cost.nil? ? false : @cards[card_id].influence_cost > 0) and @cards[card_id].card_type_id == 'program'}
          .map{|card_id, card| card.influence_cost }.sum
          influence_spent -= first_program_influence_spent
      end

      # Handle alliance cards
      if @deck['cards'].has_key?('mumba_temple') and num_cards_by_type('ice') >= 15
        influence_spent -= @deck['cards']['mumba_temple'] * @cards['mumba_temple'].influence_cost
      end

      if @deck['cards'].has_key?('mumbad_virtual_tour') and num_cards_by_type('asset') >= 7
        influence_spent -= @deck['cards']['mumbad_virtual_tour'] * @cards['mumbad_virtual_tour'].influence_cost
      end

      num_cards = @deck['cards'].map{ |slot, quantity| quantity }.sum
      if @deck['cards'].has_key?('museum_of_history') and num_cards >= 50
        influence_spent -= @deck['cards']['museum_of_history'] * @cards['museum_of_history'].influence_cost
      end

      if @deck['cards'].has_key?('pad_factory') and @deck['cards']['pad_campaign'] == 3
        influence_spent -= @deck['cards']['pad_factory'] * @cards['pad_factory'].influence_cost
      end

      # Check faction-locked alliance cards.
      @deck['cards'].each do |card_id, qty|
        if @alliance_cards.has_key?(card_id) and @cards[card_id].faction_id != @identity.faction_id
          num_non_alliance_for_faction = num_non_alliance_cards_for(@cards[card_id].faction_id)
          if num_non_alliance_for_faction >= 6
            influence_spent -= @deck['cards'][card_id] * @cards[card_id].influence_cost
          end
        end
      end
      @basic_influence_spent = influence_spent
    end
  end

  def check_cards_in_card_pool(v)
    local_errors = []
    if v.card_pool_id.nil?
      return local_errors
    end

    @deck['cards'].keys.each do |c|
      if !@card_pools_to_card_ids[v.card_pool_id].include?(c)
        local_errors << "Card `%s` is not present in Card Pool `%s`." % [c, v.card_pool_id]
      end
    end
    return local_errors
  end

end

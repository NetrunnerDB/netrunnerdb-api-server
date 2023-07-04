class DeckValidator

  attr_reader :valid
  attr_reader :errors

  # TODO: make error codes with maps for messages to aid translation and testing.
  def initialize
    @valid = false
    @errors = []
  end

  def validate(deck_json)
    if passes_request_validity?(deck_json)
      # passes_basic_deckbuilding_rules?(deck_json)
    end

    return @errors.size == 0
  end

  def passes_request_validity?(deck)
    # normalize to lowercase for all ids.

    # has identity_card_id
    has_identity = deck.has_key?(:identity_card_id)
    if not has_identity
      @errors << "Deck is missing `identity_card_id` field."
    end

    # has side_id
    has_side = deck.has_key?(:side_id)
    if not has_side
      @errors << "Deck is missing `side_id` field."
    end

    id_to_side = {}
    sides = {}
    Card.where(:card_type_id => ['corp_identity', 'runner_identity']).pluck(:id, :side_id).each do |id, side|
      id_to_side[id] = side
      sides[side] = true
    end

    # identity_card_id is valid
    if has_identity
      if not id_to_side.has_key?(deck[:identity_card_id])
        @errors << '`identity_card_id` `%s` does not exist.' % deck[:identity_card_id]
      end
    end

    # side_id is valid
    if has_side
      if not sides.has_key?(deck[:side_id])
        @errors << '`side_id` `%s` does not exist.' % deck[:side_id]
      end
    end

    # identity_card_id side matches deck side
    if has_identity and has_side
      if id_to_side[deck[:identity_card_id]] != deck[:side_id]
        @errors << 'Identity `%s` has side `%s` which does not match given side `%s`' % [deck[:identity_card_id], id_to_side[deck[:identity_card_id]], deck[:side_id]]
      end
    end

    if not (deck.has_key?(:cards) and deck[:cards].size > 0)
      @errors << "Deck must specify some cards."
    end
  end

  def passes_basic_deckbuilding_rules?(deck)
    # Check deck size minimums
    identity = Card.find(deck[:identity_card_id])

    num_cards = deck[:cards].map{ |slot| slot.quantity }.sum
    puts 'Deck has %d cards' % num_cards
    agendas_with_points = {}
    if num_cards < identity.minimum_deck_size
      @errors << "Minimum deck size is %d, but deck has %d cards." % [identity.minimum_deck_size, num_cards]
    end

#    # If corp deck, check agenda points
#    deck.cards.select{ |c| c.card_type_id == 'agenda' }.each{|c| agendas_with_points[c.id] = c.agenda_points}
#    agenda_points = deck.deck_cards.select{|slot| agendas_with_points.has_key?(slot.card_id)}.sum{|slot| slot.quantity * agendas_with_points[slot.card_id]}
#    puts 'Deck has %d agenda_points' % agenda_points
#
#    # TODO: add special Ampere agenda point rules.
#    min_agenda_points = (num_cards < identity.minimum_deck_size ? identity.minimum_deck_size : num_cards) / 5 * 2 + 2
#    required_agenda_points = [min_agenda_points, min_agenda_points + 1]
#    puts 'Deck requires %s agenda_points' % required_agenda_points.to_json
#    if not required_agenda_points.include?(agenda_points)
#      errors << "Deck with size %d requires %s agenda points, but deck only has %d" % [num_cards, required_agenda_points.to_json, agenda_points]
#    end
#
#    # TODO: add special Nova influence rules.
#    # Check influence
#    out_of_faction_cards = {}
#    deck.cards.select{ |c| c.faction_id != identity.faction_id }.each{ |c| out_of_faction_cards[c.id] = c.influence_cost }
#    influence_spent = deck.deck_cards.select{|slot| out_of_faction_cards.has_key?(slot.card_id)}.sum{|slot| slot.quantity * out_of_faction_cards[slot.card_id]}
#    puts 'Deck has spent %d influence' % influence_spent
#    if influence_spent > identity.influence_limit
#      @errors << "Influence limit for %s is %d, but deck has spent %d influence" % [identity.title, identity.influence_limit, influence_spent]
#    end
#
    return true # @errors.size == 0
  end
end

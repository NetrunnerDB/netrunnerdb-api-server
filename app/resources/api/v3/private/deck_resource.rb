module API
    module V3
      module Private
        class Api::V3::Private::DeckResource < JSONAPI::Resource
          key_type :uuid

          attributes :user_id, :follows_basic_deckbuilding_rules, :identity_card_id,
              :name, :notes, :tags, :created_at, :updated_at
          # While the Deck model has a relation for cards, we always want to return the
          # map of card ids to quantities with the deck as an attribute.
          attributes :cards, :num_cards, :influence_spent

          def cards
            cards = {}
            @model.deck_cards.each do |c|
              cards[c.card_id] = c.quantity
            end
            return cards
          end

          def num_cards
            @model.deck_cards.map{ |slot| slot.quantity }.sum
          end

          # This is the basic definition, but does not take restriction modifications
          # into account. Leaving this here as an example for now, but it will need to
          # be removed in favor of snapshot-specific calculations.
          def influence_spent
            qty = {}
            @model.deck_cards.each do |c|
              qty[c.card_id] = c.quantity
            end
            id = Card.find(@model.identity_card_id)
            @model.cards
              .filter{|c| c.faction_id != id.faction_id}
              .map{|c| c.influence_cost.nil? ? 0 : (c.influence_cost * qty[c.id])}
              .sum
          end
        end
      end
    end
  end
  
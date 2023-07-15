module API
  module V3
    module Private
      class Api::V3::Private::DeckResource < JSONAPI::Resource
        key_type :uuid

        attributes :user_id, :follows_basic_deckbuilding_rules, :identity_card_id,
            :name, :notes, :tags, :side_id, :created_at, :updated_at
        # Computed attributes
        attributes :faction_id, :cards, :num_cards, :influence_spent

        # Since some of the fields are computed or handled automatically, we don't allow
        # them to be specified for create or update operations.
        def self.creatable_fields(context)
          super - [:faction_id, :num_cards, :influence_spent, :created_at, :updated_at]
        end

        def self.updatable_fields(context)
          super - [:faction_id, :num_cards, :influence_spent, :created_at, :updated_at]
        end

        after_save do
          new_cards = context[:params]['data']['attributes']['cards']
          if new_cards
            @model.deck_cards.delete_all
            new_cards.each do |card_id, quantity|
              @model.deck_cards << @model.deck_cards.build(card_id: card_id, quantity: quantity)
            end
          end
        end

        before_create do
          @model.user_id = context[:current_user].id if @model.new_record?
          new_cards = context[:params]['data']['attributes']['cards']
          card_ids = Card.pluck(:id)
          invalid_card_ids = new_cards.keys - card_ids
          if invalid_card_ids.size > 0
            raise JSONAPI::Exceptions::InvalidFieldValue.new(
              'Deck specifies invalid card ids: %s' % invalid_card_ids.join, invalid_card_ids.join,
              {
                :title => 'Critical Deck Validation Error',
                :detail => 'Deck specifies invalid card_ids: %s' % invalid_card_ids.join
              })
          end
        end

        def self.records(options = {})
          context = options[:context]
          context[:current_user].decks
        end

        # While the Deck model has a relation for cards, we always want to return the
        # map of card ids to quantities with the deck as an attribute.
        def cards
          cards = {}
          @model.deck_cards.each do |c|
            cards[c.card_id] = c.quantity
          end
          return cards
        end

        def cards=(cards)
          # Do nothing here because we save cards in the after_save callback.
          # This is necessary due to the decision to make a tidier representation of
          # cards as a map of card_id => quantity.
          return
        end

        def num_cards
          @model.deck_cards.map{ |slot| slot.quantity }.sum
        end

        def faction_id
          id = Card.find(@model.identity_card_id)
          if id.nil?
            raise JSONAPI::Exceptions::BadRequest.new(
              'Invalid identity for deck: [%s]' % @model.identity_card_id)
          else
            return id.faction_id
          end
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

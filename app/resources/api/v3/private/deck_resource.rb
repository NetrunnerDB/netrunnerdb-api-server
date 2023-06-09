module API
  module V3
    module Private
      class Api::V3::Private::DeckResource < JSONAPI::Resource
        key_type :uuid

        attributes :user_id, :follows_basic_deckbuilding_rules, :identity_card_id,
            :name, :notes, :tags, :side_id, :created_at, :updated_at
        # Computed attributes
        attributes :faction_id, :cards, :num_cards, :influence_spent

        def self.creatable_fields(context)
          super - [:faction_id, :num_cards, :influence_spent, :created_at, :updated_at]
        end

        def self.updatable_fields(context)
          super - [:faction_id, :num_cards, :influence_spent, :created_at, :updated_at]
        end

        before_save do
          @model.user_id = context[:current_user].id if @model.new_record?
        end

        before_create :do_it

        def do_it
          Rails.logger.info 'Before create'
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

        def cards=(new_cards)
          @model.deck_cards.destroy_all
          new_cards.each do |card_id, quantity|
            # Rails.logger.info 'New card is %s with %d copies' % [card_id, quantity]
            #c = Card.find(card_id)
            #Rails.logger.info 'Card id %s has title %s' % [c.id, c.title]
            @model.deck_cards.build(card_id: card_id, quantity: quantity)
          end
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

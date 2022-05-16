module API
  module V3
    module Public
      class Api::V3::Public::PrintingResource < JSONAPI::Resource
        # Direct printing attributes
        attributes :card_id, :card_set_id, :printed_text, :stripped_printed_text, :printed_is_unique, :flavor, :illustrator, :position, :quantity, :date_release, :updated_at

        # Parent Card attributes, included inline to make printings a bit more useful.
        attributes :advancement_requirement, :agenda_points, :base_link, :card_type_id, :cost, :deck_limit
        attributes :display_subtypes, :faction_id, :influence_cost, :influence_limit, :is_unique
        attributes :memory_cost, :minimum_deck_size, :side_id, :strength, :stripped_text, :stripped_title, :text, :title, :trash_cost

        key_type :string

        has_one :card_cycle
        has_one :card_set
        has_one :side
        has_one :faction
        has_one :card

        def advancement_requirement
          @model.card.advancement_requirement
        end
        def agenda_points
          @model.card.agenda_points
        end
        def base_link
          @model.card.base_link
        end
        def card_type_id
          @model.card.card_type_id
        end
        def cost
          @model.card.cost
        end
        def deck_limit
          @model.card.deck_limit
        end
        def display_subtypes
          @model.card.display_subtypes
        end
        def faction_id
          @model.card.faction_id
        end
        def influence_cost
          @model.card.influence_cost
        end
        def influence_limit
          @model.card.influence_limit
        end
        def is_unique
          @model.card.is_unique
        end
        def memory_cost
          @model.card.memory_cost
        end
        def minimum_deck_size
          @model.card.minimum_deck_size
        end
        def side_id
          @model.card.side_id
        end
        def strength
          @model.card.strength
        end
        def stripped_text
          @model.card.stripped_text
        end
        def stripped_title
          @model.card.stripped_title
        end
        def text
          @model.card.text
        end
        def title
          @model.card.title
        end
        def trash_cost
          @model.card.trash_cost
        end
      end
    end
  end
end

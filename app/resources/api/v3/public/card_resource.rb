module API
  module V3
    module Public
      class Api::V3::Public::CardResource < JSONAPI::Resource
        immutable

        attributes :stripped_title, :title, :card_type_id, :side_id, :faction_id
        attributes :advancement_requirement, :agenda_points, :base_link, :cost
        attributes :deck_limit, :influence_cost, :influence_limit, :memory_cost
        attributes :minimum_deck_size, :strength, :stripped_text, :text, :trash_cost
        attributes :is_unique, :display_subtypes, :updated_at
        attributes :card_abilities, :latest_printing_id

        key_type :string

        has_one :side
        has_one :faction
        has_one :card_type
        has_many :card_subtypes
        has_many :printings

        def latest_printing_id
          @model.printings.max_by { |p| p.date_release } ['id']
        end

        def card_abilities
          {
            additional_cost: @model.additional_cost,
            advanceable: @model.advanceable,
            gains_subroutines: @model.gains_subroutines,
            interrupt: @model.interrupt,
            link_provided: @model.link_provided,
            mu_provided: @model.mu_provided,
            num_printed_subroutines: @model.num_printed_subroutines,
            on_encounter_effect: @model.on_encounter_effect,
            performs_trace: @model.performs_trace,
            recurring_credits_provided: @model.recurring_credits_provided,
            trash_ability: @model.trash_ability,
          }
        end

        filters :title, :card_type_id, :side_id, :faction_id, :advancement_requirement
        filters :agenda_points, :base_link, :cost, :deck_limit, :influence_cost
        filters :influence_limit, :memory_cost, :minimum_deck_size, :strength, :trash_cost, :is_unique

        filter :search, apply: ->(records, value, _options) {
          query_builder = CardSearchQueryBuilder.new(value[0])
          if query_builder.parse_error.nil?
              records.left_joins(query_builder.left_joins)
                  .where(query_builder.where, *query_builder.where_values)
          else
            raise JSONAPI::Exceptions::BadRequest.new(
                'Invalid search query: [%s] / %s' % [value[0], query_builder.parse_error])
          end
        }
      end
    end
  end
end

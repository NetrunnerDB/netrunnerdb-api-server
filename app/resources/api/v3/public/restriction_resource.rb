module API
  module V3
    module Public
      class Api::V3::Public::RestrictionResource < JSONAPI::Resource
        immutable

        attributes :name, :date_start, :point_limit
        attribute :verdicts
        attribute :banned_subtypes
        attribute :size
        attribute :updated_at
        key_type :string

        paginator :none

        def verdicts
          { 'banned': @model.banned_cards.pluck(:card_id),
            'restricted': @model.restricted_cards.pluck(:card_id),
            'universal_faction_cost': @model.universal_faction_cost_cards.pluck(:card_id, :value).to_h,
            'global_penalty': @model.global_penalty_cards.pluck(:card_id),
            'points': @model.points_cards.pluck(:card_id, :value).to_h,
          }
        end

        def banned_subtypes
          @model.banned_subtypes.pluck(:card_subtype_id)
        end

        def size
          verdicts.map { |(_,v)| v.length() }.sum
        end
      end
    end
  end
end

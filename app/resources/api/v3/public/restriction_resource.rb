module API
  module V3
    module Public
      class Api::V3::Public::RestrictionResource < JSONAPI::Resource
        attributes :name, :date_start, :point_limit
        attributes :banned, :restricted, :universal_faction_cost, :global_penalty, :points
        attribute :banned_subtypes
        attribute :updated_at
        key_type :string

        paginator :none

        def banned
          @model.banned_cards.pluck(:card_id)
        end

        def restricted
          @model.restricted_cards.pluck(:card_id)
        end

        def universal_faction_cost
          Hash[@model.universal_faction_cost_cards.pluck(:value, :card_id).group_by(&:first).map{ |k,a| [k,a.map(&:last)] }]
        end

        def global_penalty
          Hash[@model.global_penalty_cards.pluck(:value, :card_id).group_by(&:first).map{ |k,a| [k,a.map(&:last)] }]
        end

        def points
          Hash[@model.points_cards.pluck(:value, :card_id).group_by(&:first).map{ |k,a| [k,a.map(&:last)] }]
        end

        def banned_subtypes
          @model.banned_subtypes.pluck(:card_subtype_id)
        end
      end
    end
  end
end

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
          { 'banned': banned,
            'restricted': restricted,
            'universal_faction_cost': universal_faction_cost,
            'global_penalty': global_penalty,
            'points': points
          }
        end

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

        def size
          banned.length() +
          restricted.length() +
          universal_faction_cost.map { |_,a| a.length() }.sum() +
          global_penalty.map { |_,a| a.length() }.sum() +
          points.map { |_,a| a.length() }.sum()
        end
      end
    end
  end
end

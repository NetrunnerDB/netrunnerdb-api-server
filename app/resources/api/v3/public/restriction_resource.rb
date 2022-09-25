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
            'universal_faction_cost': Hash[@model.universal_faction_cost_cards.pluck(:value, :card_id).group_by(&:first).map{ |k,a| [k,a.map(&:last)] }],
            'global_penalty': @model.global_penalty_cards.pluck(:card_id),
            'points': Hash[@model.points_cards.pluck(:value, :card_id).group_by(&:first).map{ |k,a| [k,a.map(&:last)] }]
          }
        end

        def banned_subtypes
          @model.banned_subtypes.pluck(:card_subtype_id)
        end

        def size
          verdicts.reduce(0) do |n, (_,v)|
            if v.kind_of?(Array) then
              n + v.length()
            else
              n + v.reduce(0) { |m, (_,a)| m + a.length() }
            end
          end
        end
      end
    end
  end
end

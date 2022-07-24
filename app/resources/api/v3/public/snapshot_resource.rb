module API
  module V3
    module Public
      class Api::V3::Public::SnapshotResource < JSONAPI::Resource
        immutable

        attributes :format_id, :active, :card_cycle_ids, :card_set_ids, :date_start, :updated_at
        key_type :string

        paginator :none

        has_one :format
        has_one :card_pool
        has_one :restriction

        has_many :cards

        def card_cycle_ids
          @model.card_pool.card_pool_card_cycles.pluck(:card_cycle_id)
        end

        def card_set_ids
          @model.card_pool.card_pool_card_sets.pluck(:card_set_id)
        end
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::SnapshotResource < JSONAPI::Resource
        immutable

        attributes :active, :card_cycle_ids, :card_set_ids, :date_start, :updated_at
        key_type :string

        paginator :none

        belongs_to :format
        # has_one :card_pool
        has_one :restriction

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

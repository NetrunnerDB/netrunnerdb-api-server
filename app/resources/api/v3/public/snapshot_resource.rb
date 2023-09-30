module API
  module V3
    module Public
      class Api::V3::Public::SnapshotResource < JSONAPI::Resource
        caching
        immutable

        attributes :format_id, :active, :card_cycle_ids, :card_set_ids, :card_pool_id, :restriction_id, :date_start, :updated_at
        key_type :string

        attributes :num_cards

        paginator :none

        has_one :format
        has_one :card_pool
        has_one :restriction

        has_many :card_cycles
        has_many :card_sets
        has_many :cards, relation_name: :unified_cards

        filters :active, :format_id

        def card_cycle_ids
          @model.card_pool.card_pool_card_cycles.pluck(:card_cycle_id)
        end

        def card_set_ids
          @model.card_pool.card_pool_card_sets.pluck(:card_set_id)
        end

        def num_cards
          @model.card_pool.cards.length
        end
      end
    end
  end
end

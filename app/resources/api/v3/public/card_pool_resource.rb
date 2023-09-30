module API
  module V3
    module Public
      class Api::V3::Public::CardPoolResource < JSONAPI::Resource
        caching
        immutable

        attributes :name, :card_cycle_ids, :card_set_ids, :card_ids, :updated_at
        key_type :string

        attributes :num_cards

        paginator :none

        has_one :format
        has_many :card_cycles
        has_many :card_sets
        has_many :cards, relation_name: :unified_cards
        has_many :snapshots

        def num_cards
          @model.cards.length
        end
      end
    end
  end
end

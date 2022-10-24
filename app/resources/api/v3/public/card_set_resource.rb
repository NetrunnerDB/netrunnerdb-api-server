module API
  module V3
    module Public
      class Api::V3::Public::CardSetResource < JSONAPI::Resource
        immutable

        attributes :name, :date_release, :size, :card_cycle_id, :card_set_type_id, :legacy_code, :updated_at
        key_type :string

        paginator :none

        has_one :card_cycle
        has_one :card_set_type
        has_many :printings
        has_many :cards, relation_name: :unified_cards

        filters :card_cycle_id, :card_set_type_id
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::CardSubtypeResource < JSONAPI::Resource
        caching
        immutable

        attributes :name, :updated_at
        key_type :string

        paginator :none

        has_many :cards, relation_name: :unified_cards
        has_many :printings, relation_name: :unified_printings
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::FactionResource < JSONAPI::Resource
        caching
        immutable

        attributes :name, :description, :is_mini, :side_id, :updated_at
        key_type :string

        paginator :none

        has_one :side
        has_many :cards, relation_name: :unified_cards
        has_many :printings, relation_name: :unified_printings

        filters :side_id, :is_mini
      end
    end
  end
end

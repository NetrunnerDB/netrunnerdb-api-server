module API
  module V3
    module Public
      class Api::V3::Public::CardTypeResource < JSONAPI::Resource
        immutable

        attributes :name, :side_id, :updated_at
        key_type :string

        has_one :side
        has_many :cards, relation_name: :unified_cards
        paginator :none

        filter :side_id
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::FactionResource < JSONAPI::Resource
        immutable

        attributes :name, :is_mini, :side_id, :updated_at
        key_type :string

        paginator :none

        has_one :side
        has_many :cards
        has_many :printings

        filters :side_id, :is_mini
      end
    end
  end
end

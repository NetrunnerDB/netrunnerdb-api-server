module API
  module V3
    module Public
      class Api::V3::Public::FactionResource < JSONAPI::Resource
        attributes :name, :is_mini, :updated_at
        key_type :string

        paginator :none

        has_one :side
        has_many :cards
        has_many :printings
      end
    end
  end
end

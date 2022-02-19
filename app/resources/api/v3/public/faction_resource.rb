module API
  module V3
    module Public
      class Api::V3::Public::FactionResource < JSONAPI::Resource
        attributes :name, :is_mini, :updated_at
        key_type :string

        paginator :none

        has_many :cards
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::CardTypeResource < JSONAPI::Resource
        attributes :name, :updated_at
        key_type :string

        has_many :cards
        paginator :none
      end
    end
  end
end

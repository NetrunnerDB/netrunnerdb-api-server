module API
  module V3
    module Public
      class Api::V3::Public::CardSetTypeResource < JSONAPI::Resource
        attributes :name, :description, :updated_at
        key_type :string
      end
    end
  end
end

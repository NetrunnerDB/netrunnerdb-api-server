module API
  module V3
    module Public
      class Api::V3::Public::CardCycleResource < JSONAPI::Resource
        attributes :name, :description, :updated_at
        key_type :string
      end
    end
  end
end

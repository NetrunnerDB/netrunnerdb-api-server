module API
  module V3
    module Public
      class Api::V3::Public::SideResource < JSONAPI::Resource
        attributes :name, :updated_at
        key_type :string
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::SubtypeResource < JSONAPI::Resource
        attributes :name, :updated_at
        key_type :string

        paginator :offset
      end
    end
  end
end

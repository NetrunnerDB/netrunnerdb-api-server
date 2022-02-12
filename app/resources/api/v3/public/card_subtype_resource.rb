module API
  module V3
    module Public
      class Api::V3::Public::CardSubtypeResource < JSONAPI::Resource
        model_name 'Subtype' 
        primary_key :code
        attributes :code, :name, :updated_at
        key_type :string

        paginator :offset
      end
    end
  end
end

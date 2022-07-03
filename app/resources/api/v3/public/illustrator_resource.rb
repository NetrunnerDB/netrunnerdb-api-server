module API
  module V3
    module Public
      class Api::V3::Public::IllustratorResource < JSONAPI::Resource
        immutable

        attributes :name, :updated_at
        key_type :string

        paginator :none

        has_many :printings
      end
    end
  end
end

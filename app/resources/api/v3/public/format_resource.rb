module API
  module V3
    module Public
      class Api::V3::Public::FormatResource < JSONAPI::Resource
        attributes :name, :active, :updated_at
        key_type :string

        paginator :none

        has_many :rotations
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::RotationResource < JSONAPI::Resource
        attributes :name, :date_start, :format_id, :updated_at
        key_type :string

        paginator :none

        belongs_to :format
        has_many :card_sets
      end
    end
  end
end

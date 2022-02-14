module API
  module V3
    module Public
      class Api::V3::Public::CardCycleResource < JSONAPI::Resource
        attributes :name, :description, :updated_at
        key_type :string

        has_many :card_sets
        paginator :none
      end
    end
  end
end

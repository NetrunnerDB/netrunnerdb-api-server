module API
  module V3
    module Public
      class Api::V3::Public::CardCycleResource < JSONAPI::Resource
        immutable

        attributes :name, :date_release, :updated_at
        key_type :string

        has_many :card_sets
        has_many :printings
        has_many :cards

        paginator :none
      end
    end
  end
end

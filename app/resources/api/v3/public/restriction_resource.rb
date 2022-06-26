module API
  module V3
    module Public
      class Api::V3::Public::RestrictionResource < JSONAPI::Resource
        attributes :name, :date_start, :point_limit, :updated_at
        key_type :string

        paginator :none

        has_many :restriction_cards
        has_many :restriction_subtypes
      end
    end
  end
end

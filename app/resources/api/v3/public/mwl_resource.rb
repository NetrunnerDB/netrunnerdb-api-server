module API
  module V3
    module Public
      class Api::V3::Public::MwlResource < JSONAPI::Resource
        attributes :name, :date_start, :point_limit, :updated_at
        key_type :string

        paginator :none

        has_many :mwl_cards
        has_many :mwl_subtypes
      end
    end
  end
end

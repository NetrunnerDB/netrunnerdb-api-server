module API
  module V3
    module Public
      class Api::V3::Public::SideResource < JSONAPI::Resource
        immutable

        attributes :name, :updated_at
        key_type :string

        paginator :none

        has_many :factions
        has_many :printings
        has_many :cards
      end
    end
  end
end

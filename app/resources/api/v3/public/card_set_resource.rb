module API
  module V3
    module Public
      class Api::V3::Public::CardSetResource < JSONAPI::Resource
        # TODO(plural): Add relationships in here.
        attributes :name, :date_release, :size, :card_cycle_id, :card_set_type_id, :updated_at
        key_type :string

        paginator :none

        has_one :card_cycle
        has_many :printings
      end
    end
  end
end

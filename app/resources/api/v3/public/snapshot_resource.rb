module API
  module V3
    module Public
      class Api::V3::Public::SnapshotResource < JSONAPI::Resource
        immutable
        
        attributes :format_id, :active, :date_start, :updated_at
        key_type :string

        paginator :none

        belongs_to :format
        has_one :card_pool
        has_one :restriction
        has_many :cards
      end
    end
  end
end

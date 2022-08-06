module API
  module V3
    module Public
      class Api::V3::Public::FormatResource < JSONAPI::Resource
        immutable

        attributes :name, :active_snapshot_id, :snapshot_ids, :updated_at
        key_type :string

        paginator :none

        has_many :card_pools
        has_many :restrictions
        has_many :snapshots
      end
    end
  end
end

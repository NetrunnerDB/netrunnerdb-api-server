module API
  module V3
    module Public
      class Api::V3::Public::FormatResource < JSONAPI::Resource
        attributes :name, :active_snapshot_id, :updated_at
        key_type :string

        paginator :none

        has_many :snapshots
      end
    end
  end
end

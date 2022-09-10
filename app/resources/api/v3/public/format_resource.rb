module API
  module V3
    module Public
      class Api::V3::Public::FormatResource < JSONAPI::Resource
        immutable

        attributes :name, :active_snapshot_id, :snapshot_ids
        attribute :active_restriction_id
        attribute :updated_at
        key_type :string

        paginator :none

        has_many :card_pools
        has_many :restrictions
        has_many :snapshots

        def active_restriction_id
          @model.snapshots.find_by(active: true).restriction_id
        end
      end
    end
  end
end

module API
  module V3
    module Public
      class Api::V3::Public::FormatResource < JSONAPI::Resource
        caching
        immutable

        attributes :name, :active_snapshot_id, :snapshot_ids, :restriction_ids, :updated_at
        attributes :active_card_pool_id, :active_restriction_id
        key_type :string

        paginator :none

        has_many :card_pools
        has_many :restrictions
        has_many :snapshots

        def active_card_pool_id
          @model.snapshots.find_by(active: true).card_pool_id
        end

        def active_restriction_id
          @model.snapshots.find_by(active: true).restriction_id
        end

        def snapshot_ids
          @model.snapshots.sort_by { |s| s.date_start }.map { |s| s.id }
        end

        def restriction_ids
          @model.restrictions.sort_by { |r| r.date_start }.map { |r| r.id }
        end
      end
    end
  end
end

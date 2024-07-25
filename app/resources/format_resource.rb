# frozen_string_literal: true

# Public resource for Format objects.
class FormatResource < ApplicationResource
  primary_endpoint '/formats', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :active_snapshot_id, :string
  attribute :snapshot_ids, :array_of_strings do
    @object.snapshots.sort_by(&:date_start).map(&:id)
  end
  attribute :restriction_ids, :array_of_strings do
    @object.restrictions.sort_by(&:date_start).map(&:id)
  end
  attribute :active_card_pool_id, :string
  attribute :active_restriction_id, :string
  attribute :updated_at, :datetime

  has_many :card_pools
  has_many :snapshots
  has_many :restrictions
end

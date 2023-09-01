# frozen_string_literal: true

class Format < ApplicationRecord
  has_many :card_pools
  has_many :snapshots
  has_many :card_pools, :through => :snapshots
  has_many :restrictions, :through => :snapshots

  has_one :snapshot, primary_key: :active_snapshot_id, foreign_key: :id

  validates :name, uniqueness: true
end

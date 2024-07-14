# frozen_string_literal: true

class Format < ApplicationRecord
  has_many :card_pools
  has_many :snapshots
  has_many :restrictions, through: :snapshots

  has_one :snapshot, primary_key: :active_snapshot_id, foreign_key: :id

  def active_card_pool_id
    s = snapshots.where(active: true).first
    return if s.nil?

    s.card_pool_id
  end

  def active_restriction_id
    s = snapshots.where(active: true).first
    return if s.nil?

    s.restriction_id
  end

  validates :name, uniqueness: true
end

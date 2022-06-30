# frozen_string_literal: true

class Format < ApplicationRecord
  has_many :card_pools
  has_many :snapshots
  has_many :card_pools, :through => :snapshots
  has_many :restrictions, :through => :snapshots

  validates :name, uniqueness: true
end

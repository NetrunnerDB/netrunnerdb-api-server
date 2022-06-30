# frozen_string_literal: true

class Restriction < ApplicationRecord
  has_many :snapshots

  validates :name, uniqueness: true
end

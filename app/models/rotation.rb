# frozen_string_literal: true

class Rotation < ApplicationRecord
  belongs_to :format
  has_many :rotation_sets
  has_many :card_sets, :through => :rotation_sets

  validates :name, uniqueness: true
end

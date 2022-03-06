# frozen_string_literal: true

class Rotation < ApplicationRecord
  belongs_to :format
  has_many :rotation_cycles
  has_many :card_cycles, :through => :rotation_cycles
  has_many :rotation_sets
  has_many :card_sets, :through => :rotation_sets
  has_many :rotation_cards
  has_many :cards, :through => :rotation_cards

  validates :name, uniqueness: true
end

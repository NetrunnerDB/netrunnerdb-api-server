# frozen_string_literal: true

class CardCycle < ApplicationRecord
  has_many :card_sets
  # TODO(plural): Add association path for cycles -> printings
  has_many :rotation_cycles
  has_many :rotations, :through => :rotation_cycles
end

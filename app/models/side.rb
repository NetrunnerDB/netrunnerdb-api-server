# frozen_string_literal: true

class Side < ApplicationRecord
  has_many :cards
  has_many :factions
end

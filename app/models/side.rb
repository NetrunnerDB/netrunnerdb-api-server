# frozen_string_literal: true

class Side < ApplicationRecord
  has_many :factions
  has_many :cards
  has_many :printings, :through => :cards
end

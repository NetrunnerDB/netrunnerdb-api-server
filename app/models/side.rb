# frozen_string_literal: true

class Side < ApplicationRecord
  has_many :factions
  has_many :card_types
  has_many :cards
  has_many :decklists
  has_many :printings, :through => :cards
  has_many :unified_printings, :through => :cards
end

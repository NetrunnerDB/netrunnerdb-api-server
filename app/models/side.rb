# frozen_string_literal: true

# Model for Side objects.
class Side < ApplicationRecord
  has_many :factions
  has_many :card_types
  has_many :cards
  has_many :decklists
  has_many :raw_printings,
           through: :cards,
           foreign_key: :card_id,
           primary_key: :id
  has_many :printings, through: :cards
end

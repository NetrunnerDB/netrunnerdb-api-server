# frozen_string_literal: true

# Model for Card Type objects.
class CardType < ApplicationRecord
  belongs_to :side
  has_many :cards
  has_many :printings
end

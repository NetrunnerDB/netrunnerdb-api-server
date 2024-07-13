# frozen_string_literal: true

class CardSet < ApplicationRecord
  belongs_to :card_cycle
  belongs_to :card_set_type

  has_many :raw_printings
  has_many :printings
  has_many :raw_cards, through: :raw_printings, source: :raw_card
  has_many :cards, through: :printings
end

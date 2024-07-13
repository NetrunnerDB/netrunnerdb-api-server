# frozen_string_literal: true

class CardSubtype < ApplicationRecord
  has_many :card_card_subtypes
  has_many :cards, through: :card_card_subtypes
  has_many :printing_card_subtypes
  has_many :raw_printings, through: :printing_card_subtypes
  has_many :printings, through: :printing_card_subtypes, primary_key: :printing_id, foreign_key: :id
end

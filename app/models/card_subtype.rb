# frozen_string_literal: true

class CardSubtype < ApplicationRecord
  has_many :card_card_subtypes
  has_many :cards, :through => :card_card_subtypes
  has_many :printings, :through => :cards
  has_many :unified_cards, :through => :card_card_subtypes, primary_key: :card_id, foreign_key: :id
  has_many :unified_printings, :through => :cards
end

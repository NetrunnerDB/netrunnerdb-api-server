# frozen_string_literal: true

class CardSubtype < ApplicationRecord
  has_many :card_card_subtypes
  has_many :cards, :through => :card_card_subtypes
end

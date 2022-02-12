# frozen_string_literal: true

class CardType < ApplicationRecord
  self.primary_key = "code"

  has_many :cards
end

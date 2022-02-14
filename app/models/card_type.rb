# frozen_string_literal: true

class CardType < ApplicationRecord
  has_many :cards
end

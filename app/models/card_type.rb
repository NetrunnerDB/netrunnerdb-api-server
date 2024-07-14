# frozen_string_literal: true

class CardType < ApplicationRecord
  belongs_to :side
  has_many :cards
  has_many :printings
end

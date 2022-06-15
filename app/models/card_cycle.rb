# frozen_string_literal: true

class CardCycle < ApplicationRecord
  has_many :card_sets
  has_many :printings, :through => :card_sets
  has_many :cards, :through => :printings
end

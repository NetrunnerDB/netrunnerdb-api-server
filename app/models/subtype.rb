# frozen_string_literal: true

class Subtype < ApplicationRecord
  has_many :card_subtypes
  has_many :cards, :through => :card_subtypes
end

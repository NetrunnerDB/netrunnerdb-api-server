# frozen_string_literal: true

class Card < ApplicationRecord
  belongs_to :side
  belongs_to :faction
  belongs_to :card_type
  has_many :card_card_subtypes
  has_many :card_subtypes, :through => :card_card_subtypes
  has_many :printings

  validates :name, uniqueness: true
end

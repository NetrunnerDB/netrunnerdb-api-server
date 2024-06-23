# frozen_string_literal: true

class Faction < ApplicationRecord
  belongs_to :side
  has_many :cards
  # TODO(plural): Add decklist relationship
  has_many :printings, :through => :cards
  has_many :unified_cards
  has_many :unified_printings, :through => :cards
end

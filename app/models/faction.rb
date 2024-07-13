# frozen_string_literal: true

class Faction < ApplicationRecord
  belongs_to :side
  has_many :cards
  has_many :raw_printings, :through => :cards
  has_many :printings, :through => :cards
end

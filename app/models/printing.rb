# frozen_string_literal: true

class Printing < ApplicationRecord
  belongs_to :card
  belongs_to :card_set
  has_one :faction, :through => :card
  has_one :card_cycle, :through => :card_set
  has_one :side, :through => :card
end

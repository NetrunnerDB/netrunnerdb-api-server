# frozen_string_literal: true

class CardSet < ApplicationRecord
  belongs_to :card_cycle
  belongs_to :card_set_type

  has_many :printings
end

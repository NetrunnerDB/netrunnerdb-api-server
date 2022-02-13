# frozen_string_literal: true

class CardType < ApplicationRecord
  self.primary_key = :code

  has_many :cards,
    :primary_key => :code,
    :foreign_key => :card_type_code
end

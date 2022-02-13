# frozen_string_literal: true

class CardSetType < ApplicationRecord
  self.primary_key = :code

  has_many :card_sets,
    :primary_key => :code,
    :foreign_key => :card_set_type_code
end

# frozen_string_literal: true

class Subtype < ApplicationRecord
  self.primary_key = :code

  has_many :card_subtypes,
    :primary_key => :code,
    :foreign_key => :subtype_code
  has_many :cards, :through => :card_subtypes
end

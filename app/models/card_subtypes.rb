# frozen_string_literal: true

class CardSubtypes < ApplicationRecord
  self.primary_key = "code"

  belongs_to :cards
  belongs_to :subtypes
end

# frozen_string_literal: true

class Side < ApplicationRecord
  self.primary_key = "code"

  has_many :cards
end

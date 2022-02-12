# frozen_string_literal: true

class Faction < ApplicationRecord
  self.primary_key = "code"

  has_many :cards
end

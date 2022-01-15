# frozen_string_literal: true

class Faction < ApplicationRecord
  has_many :cards
end

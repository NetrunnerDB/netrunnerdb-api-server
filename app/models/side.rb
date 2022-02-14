# frozen_string_literal: true

class Side < ApplicationRecord
  # TODO(plural): Add an association for factions.
  has_many :cards
end

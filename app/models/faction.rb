# frozen_string_literal: true

# TODO(plural): add a side code to faction.
class Faction < ApplicationRecord
  has_many :cards
end

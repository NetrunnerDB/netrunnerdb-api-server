# frozen_string_literal: true

# Model for Card Set Type objects.
class CardSetType < ApplicationRecord
  has_many :card_sets
end

# frozen_string_literal: true

# Model for Card Faces - flip cards, cards with multiple versions, etc.
class PrintingFace < ApplicationRecord
  belongs_to :printing
end

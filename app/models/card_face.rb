# frozen_string_literal: true

# Model for Card Faces - flip cards, cards with multiple versions, etc.
class CardFace < ApplicationRecord
  belongs_to :card
  has_many :card_face_card_subtypes
  has_many :card_subtypes, through: :card_face_card_subtypes
end

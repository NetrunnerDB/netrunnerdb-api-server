# frozen_string_literal: true

class CardFace < ApplicationRecord
  belongs_to :card
  has_many :card_face_card_subtypes
  has_many :card_subtypes, through: :card_face_card_subtypes
end

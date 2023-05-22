# frozen_string_literal: true

class CardFace < ApplicationRecord
  has_one :card_card_face
  has_one :card, :through => :card_card_face
  has_one :unified_card, :through => :card_card_face, primary_key: :card_id, foreign_key: :id
  has_many :card_face_card_subtypes
  has_many :card_subtypes, :through => :card_face_card_subtypes
end

# frozen_string_literal: true

class CardFaceCardSubtype < ApplicationRecord
  self.table_name = "card_faces_card_subtypes"

  belongs_to :card_face,
    :primary_key => :id,
    :foreign_key => :card_face_id
  belongs_to :card_subtype,
    :primary_key => :id,
    :foreign_key => :card_subtype_id
 end

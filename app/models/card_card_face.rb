# frozen_string_literal: true

class CardCardFace < ApplicationRecord
  self.table_name = "cards_card_faces"

  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :card_face,
    :primary_key => :id,
    :foreign_key => :card_face_id
  belongs_to :unified_card,
    :primary_key => :id,
    :foreign_key => :card_id
 end

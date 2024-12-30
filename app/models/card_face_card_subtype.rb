# frozen_string_literal: true

class CardFaceCardSubtype < ApplicationRecord
  self.table_name = 'card_faces_card_subtypes'

  belongs_to :card_face,
             primary_key: %i[card_id face_index],
             query_constraints: %i[card_id face_index]
  belongs_to :card_subtype,
             primary_key: :id
end

# frozen_string_literal: true

class PrintingFaceIllustrator < ApplicationRecord
  self.table_name = "printing_faces_illustrators"

  belongs_to :printing_face,
    :primary_key => :id,
    :foreign_key => :printing_face_id
  belongs_to :illustrator,
    :primary_key => :id,
    :foreign_key => :illustrator_id
 end

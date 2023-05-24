# frozen_string_literal: true

class PrintingPrintingFace < ApplicationRecord
  self.table_name = "printings_printing_faces"

  belongs_to :printing,
    :primary_key => :id,
    :foreign_key => :printing_id
  belongs_to :printing_face,
    :primary_key => :id,
    :foreign_key => :printing_face_id
  belongs_to :unified_printing,
    :primary_key => :id,
    :foreign_key => :printing_id
 end

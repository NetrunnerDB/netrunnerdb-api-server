# frozen_string_literal: true

class PrintingFace < ApplicationRecord
  has_one :printing_printing_face
  has_one :printing, :through => :printing_printing_face
  has_one :unified_printing, :through => :printing_printing_face, primary_key: :printing_id, foreign_key: :id
  has_many :printing_face_illustrators
  has_many :illustrators, :through => :printing_face_illustrators
end

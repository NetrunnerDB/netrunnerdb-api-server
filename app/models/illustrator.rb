# frozen_string_literal: true

class Illustrator < ApplicationRecord
  has_many :illustrator_printings
  has_many :raw_printings, :through => :illustrator_printings, foreign_key: :printing_id, primary_key: :id
  has_many :printings, :through => :illustrator_printings, foreign_key: :printing_id, primary_key: :id
end

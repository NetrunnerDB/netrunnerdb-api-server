# frozen_string_literal: true

class Illustrator < ApplicationRecord
  has_many :illustrator_printings
  has_many :printings, :through => :illustrator_printings
  has_many :unified_printings, :through => :illustrator_printings
end

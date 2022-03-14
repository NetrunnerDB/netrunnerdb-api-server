# frozen_string_literal: true

class Format < ApplicationRecord
  has_many :rotations

  validates :name, uniqueness: true
end

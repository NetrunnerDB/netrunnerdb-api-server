# frozen_string_literal: true

class Subtype < ApplicationRecord
  has_and_belongs_to_many :cards
end

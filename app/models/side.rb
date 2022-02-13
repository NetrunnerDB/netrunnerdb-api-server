# frozen_string_literal: true

class Side < ApplicationRecord
  self.primary_key = :code

  # TODO(plural): Add an association for factions.
  has_many :cards,
    :primary_key => :code,
    :foreign_key => :side_code
end

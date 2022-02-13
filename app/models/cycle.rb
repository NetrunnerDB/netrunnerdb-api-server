# frozen_string_literal: true

class Cycle < ApplicationRecord
  self.primary_key = :code

  # TODO(plural): Add association path for cycles -> printings
  has_many :card_sets,
    :primary_key => :code,
    :foreign_key => :cycle_code
end

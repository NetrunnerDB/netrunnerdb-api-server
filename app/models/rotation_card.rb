# frozen_string_literal: true

class RotationCard < ApplicationRecord
  self.table_name = "rotations_cards"

  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :rotation,
    :primary_key => :id,
    :foreign_key => :rotation_id
end

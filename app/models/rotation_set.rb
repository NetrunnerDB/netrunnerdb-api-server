# frozen_string_literal: true

class RotationSet < ApplicationRecord
  self.table_name = "rotations_sets"

  belongs_to :card_set,
    :primary_key => :id,
    :foreign_key => :card_set_id
  belongs_to :rotation,
    :primary_key => :id,
    :foreign_key => :rotation_id
end

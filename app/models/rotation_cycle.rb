# frozen_string_literal: true

class RotationCycle < ApplicationRecord
  self.table_name = "rotations_cycles"

  belongs_to :card_cycle,
    :primary_key => :id,
    :foreign_key => :card_cycle_id
  belongs_to :rotation,
    :primary_key => :id,
    :foreign_key => :rotation_id
end

# frozen_string_literal: true

class CardSet < ApplicationRecord
  self.primary_key = :code

  belongs_to :cycle,
    optional: true,
    :primary_key => :code,
    :foreign_key => :cycle_code
  belongs_to :card_set_type,
    :primary_key => :code,
    :foreign_key => :card_set_type_code
end

# frozen_string_literal: true

class RestrictionCard < ApplicationRecord
  self.table_name = "restrictions_cards"

  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :restriction,
    :primary_key => :id,
    :foreign_key => :restriction_id
end

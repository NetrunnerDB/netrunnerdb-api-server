# frozen_string_literal: true

class RestrictionCardRestricted < ApplicationRecord
  self.table_name = "restrictions_cards_restricted"

  belongs_to :restriction,
    :primary_key => :id,
    :foreign_key => :restriction_id
  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
end

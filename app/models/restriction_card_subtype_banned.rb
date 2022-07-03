# frozen_string_literal: true

class RestrictionCardSubtypeBanned < ApplicationRecord
  self.table_name = "restrictions_card_subtypes_banned"

  belongs_to :restriction,
    :primary_key => :id,
    :foreign_key => :restriction_id
  belongs_to :card_subtype,
    :primary_key => :id,
    :foreign_key => :card_subtype_id
end

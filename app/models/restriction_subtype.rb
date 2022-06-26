# frozen_string_literal: true

class RestrictionSubtype < ApplicationRecord
  self.table_name = "restrictions_subtypes"

  belongs_to :card_subtype,
    :primary_key => :id,
    :foreign_key => :card_subtype_id
  belongs_to :restriction,
    :primary_key => :id,
    :foreign_key => :restriction_id
end

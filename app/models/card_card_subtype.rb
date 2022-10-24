# frozen_string_literal: true

class CardCardSubtype < ApplicationRecord
  self.table_name = "cards_card_subtypes"

  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :card_subtype,
    :primary_key => :id,
    :foreign_key => :card_subtype_id
  belongs_to :unified_card,
    :primary_key => :id,
    :foreign_key => :card_id
 end

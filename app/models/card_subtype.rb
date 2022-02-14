# frozen_string_literal: true

class CardSubtype < ApplicationRecord
  self.table_name = "cards_subtypes"

  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :subtype,
    :primary_key => :id,
    :foreign_key => :subtype_id
end

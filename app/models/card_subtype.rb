# frozen_string_literal: true

class CardSubtype < ApplicationRecord
  self.table_name = "cards_subtypes"

  belongs_to :cards,
    :class_name => "Card",
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :subtypes,
    :class_name => "Subtype",
    :primary_key => :id,
    :foreign_key => :subtype_id
end

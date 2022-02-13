# frozen_string_literal: true

class CardSubtype < ApplicationRecord
  self.table_name = "cards_subtypes"

  belongs_to :cards,
    :class_name => "Card",
    :primary_key => :code,
    :foreign_key => :card_code
  belongs_to :subtypes,
    :class_name => "Subtype",
    :primary_key => :code,
    :foreign_key => :subtype_code
end

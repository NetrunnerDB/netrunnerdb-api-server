# frozen_string_literal: true

class PrintingCardSubtype < ApplicationRecord
  self.table_name = 'printings_card_subtypes'

  belongs_to :printing
  belongs_to :card_subtype
  belongs_to :unified_sprinting,
             foreign_key: :printing_id
end

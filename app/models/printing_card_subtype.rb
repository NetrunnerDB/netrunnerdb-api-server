# frozen_string_literal: true

# Model for printings_card_subtypes join table.
class PrintingCardSubtype < ApplicationRecord
  self.table_name = 'printings_card_subtypes'

  belongs_to :printing
  belongs_to :card_subtype
end

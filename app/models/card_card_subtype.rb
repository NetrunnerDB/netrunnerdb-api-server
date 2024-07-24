# frozen_string_literal: true

# Model for cards_card_subtypes join table.
class CardCardSubtype < ApplicationRecord
  self.table_name = 'cards_card_subtypes'

  belongs_to :card,
             primary_key: :id
  belongs_to :card_subtype,
             primary_key: :id
  belongs_to :raw_card,
             inverse_of: :card_subtypes,
             primary_key: :id,
             foreign_key: :card_id
end

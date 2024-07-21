# frozen_string_literal: true

# Model for decks_cards join table.
class DeckCard < ApplicationRecord
  self.table_name = 'decks_cards'

  belongs_to :deck,
             primary_key: :id,
             inverse_of: :card_slots,
             touch: true
  belongs_to :card,
             primary_key: :id
end

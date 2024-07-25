# frozen_string_literal: true

# Model for decklists_cards join table.
class DecklistCard < ApplicationRecord
  self.table_name = 'decklists_cards'

  belongs_to :decklist,
             primary_key: :id,
             inverse_of: :decklist_cards,
             touch: true
  belongs_to :card,
             primary_key: :id
end

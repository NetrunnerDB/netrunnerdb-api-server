# frozen_string_literal: true

class DecklistCard < ApplicationRecord
  self.table_name = "decklists_cards"

  belongs_to :decklist,
    :primary_key => :id,
    :foreign_key => :decklist_id,
    :inverse_of => :decklist_cards,
    :touch => true
  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
 end

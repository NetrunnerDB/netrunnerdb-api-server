# frozen_string_literal: true

class DeckCard < ApplicationRecord
  self.table_name = "decks_cards"

  belongs_to :deck,
    :primary_key => :id,
    :foreign_key => :deck_id
  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
 end

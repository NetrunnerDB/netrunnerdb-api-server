# frozen_string_literal: true
class Card < ApplicationRecord
  self.table_name = 'unified_cards'
  include CardAbilities

  self.primary_key = :id

  belongs_to :card_type
  belongs_to :faction
  belongs_to :side

  scope :by_card_cycle, ->(card_cycle_id) {
    where(id: UnifiedPrinting.select(:card_id).where(card_cycle_id: card_cycle_id))
  }
  scope :by_card_set, ->(card_set_id) {
    where(id: UnifiedPrinting.select(:card_id).where(card_set_id: card_set_id))
  }

  has_many :card_card_subtypes,
           primary_key: :id,
           foreign_key: :card_id

  has_many :card_subtypes, through: :card_card_subtypes

  has_many :printings,
           class_name: 'UnifiedPrinting',
           primary_key: :id,
           foreign_key: :card_id

  has_many :card_cycles, through: :printings

  has_many :rulings,
           primary_key: :id,
           foreign_key: :card_id

  # Private decks
  has_many :deck_cards, primary_key: :id, foreign_key: :card_id
  has_many :decks, through: :deck_cards, primary_key: :id, foreign_key: :card_id

  # Public decklists
  has_many :decklist_cards, primary_key: :id, foreign_key: :card_id
  has_many :decklists, through: :decklist_cards, primary_key: :id, foreign_key: :card_id
end

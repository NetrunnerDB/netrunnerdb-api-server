# frozen_string_literal: true

# Model for Card objects.
#
# This uses the unified_cards table because it pre-joins the useful data from related tables.
# These records are immutable since they are sourced from a materialized view.
class Card < ApplicationRecord
  self.table_name = 'unified_cards'
  include CardAbilities

  self.primary_key = :id

  def latest_printing_id
    printing_ids_in_database[0]
  rescue StandardError
    nil
  end

  def restrictions
    {
      banned: restrictions_banned,
      global_penalty: restrictions_global_penalty,
      points: packed_restriction_to_map(restrictions_points),
      restricted: restrictions_restricted,
      universal_faction_cost: packed_restriction_to_map(restrictions_universal_faction_cost)
    }
  end

  belongs_to :card_type
  belongs_to :faction
  belongs_to :side

  scope :by_card_cycle, lambda { |card_cycle_id|
    where(id: Printing.select(:card_id).where(card_cycle_id:))
  }
  scope :by_card_set, lambda { |card_set_id|
    where(id: Printing.select(:card_id).where(card_set_id:))
  }

  has_many :card_card_subtypes,
           primary_key: :id

  has_many :card_pool_cards
  has_many :card_pools, through: :card_pool_cards

  has_many :card_subtypes, through: :card_card_subtypes

  has_many :raw_printings,
           class_name: 'RawPrinting',
           primary_key: :id

  has_many :reviews
  has_many :printings,
           primary_key: :id

  has_many :card_cycles, through: :printings
  has_many :card_sets, through: :printings

  has_many :rulings,
           primary_key: :id

  # Private decks
  has_many :deck_cards, primary_key: :id
  has_many :decks, through: :deck_cards, primary_key: :id

  # Public decklists
  has_many :decklist_cards, primary_key: :id
  has_many :decklists, through: :decklist_cards, primary_key: :id

  private

  def packed_restriction_to_map(packed)
    m = {}
    packed.each do |p|
      x = p.split('=')
      m[x[0]] = x[1].to_i
    end
    m
  end
end

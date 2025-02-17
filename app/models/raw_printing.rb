# frozen_string_literal: true

# Simple model based on direct import of rhte Printing records from JSON data.
# This should not be used except for the importer and as the base data for the
# UnifiedPrinting materialized view.
class RawPrinting < ApplicationRecord
  self.table_name = 'printings'

  belongs_to :card_set
  belongs_to :raw_card, inverse_of: :raw_printings, primary_key: :id, foreign_key: :card_id
  has_one :faction, through: :card
  has_one :card_cycle, through: :card_set
  has_one :card_type, through: :card
  has_many :printing_card_subtypes
  has_many :card_subtypes, through: :printing_card_subtypes
  has_one :side, through: :card
  has_many :illustrator_printings
  has_many :illustrators, through: :illustrator_printings

  has_many :unified_restrictions, inverse_of: :resriction, primary_key: :card_id, foreign_key: :card_id
  has_many :card_pool_cards, primary_key: :card_id, foreign_key: :card_id # rubocop:disable Rails/InverseOf
  has_many :card_pools, through: :card_pool_cards
end

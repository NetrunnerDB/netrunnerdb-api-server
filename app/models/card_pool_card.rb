# frozen_string_literal: true

# Model for card_pools_cards join table.
class CardPoolCard < ApplicationRecord
  self.table_name = 'card_pools_cards'

  belongs_to :card,
             primary_key: :id
  belongs_to :card_pool,
             primary_key: :id
  belongs_to :raw_card,
             inverse_of: :card_pool_cards,
             primary_key: :id,
             foreign_key: :card_id
  has_many :printings, through: :card
end

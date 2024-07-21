# frozen_string_literal: true

class CardPoolCard < ApplicationRecord
  self.table_name = 'card_pools_cards'

  belongs_to :card,
             primary_key: :id
  belongs_to :card_pool,
             primary_key: :id
  belongs_to :unified_card,
             primary_key: :id,
             foreign_key: :card_id
  has_many :printings, through: :card
end

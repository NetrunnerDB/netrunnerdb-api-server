# frozen_string_literal: true

# Model for card_pools_card_cycles join table.
class CardPoolCardCycle < ApplicationRecord
  self.table_name = 'card_pools_card_cycles'

  belongs_to :card_cycle,
             primary_key: :id
  belongs_to :card_pool,
             primary_key: :id
end

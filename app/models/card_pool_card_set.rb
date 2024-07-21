# frozen_string_literal: true

# Model for card_pools_card_sets join table.
class CardPoolCardSet < ApplicationRecord
  self.table_name = 'card_pools_card_sets'

  belongs_to :card_set,
             primary_key: :id
  belongs_to :card_pool,
             primary_key: :id
end

# frozen_string_literal: true

class CardPoolCard < ApplicationRecord
  self.table_name = "card_pools_cards"

  belongs_to :card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :card_pool,
    :primary_key => :id,
    :foreign_key => :card_pool_id
end

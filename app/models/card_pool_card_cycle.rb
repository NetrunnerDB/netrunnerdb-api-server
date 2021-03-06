# frozen_string_literal: true

class CardPoolCardCycle < ApplicationRecord
  self.table_name = "card_pools_card_cycles"

  belongs_to :card_cycle,
    :primary_key => :id,
    :foreign_key => :card_cycle_id
  belongs_to :card_pool,
    :primary_key => :id,
    :foreign_key => :card_pool_id
end

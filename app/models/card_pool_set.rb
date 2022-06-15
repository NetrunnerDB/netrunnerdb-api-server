# frozen_string_literal: true

class CardPoolSet < ApplicationRecord
  self.table_name = "card_pools_sets"

  belongs_to :card_set,
    :primary_key => :id,
    :foreign_key => :card_set_id
  belongs_to :card_pool,
    :primary_key => :id,
    :foreign_key => :card_pool_id
end

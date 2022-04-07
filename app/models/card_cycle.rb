# frozen_string_literal: true

class CardCycle < ApplicationRecord
  has_many :card_sets
  # TODO(plural): Add association path for cycles -> printings
  has_many :card_pool_cycles
  has_many :card_pools, :through => :card_pool_cycles
end

# frozen_string_literal: true

class CardCycle < ApplicationRecord
  has_many :card_sets
  has_many :printings, class_name: 'UnifiedPrinting'
  has_many :unified_printings
  has_many :cards, :through => :printings
  has_many :card_pool_card_cycles
  has_many :card_pools, :through => :card_pool_card_cycles
end

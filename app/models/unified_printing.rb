class UnifiedPrinting < ApplicationRecord
  include CardAbilities

  self.primary_key = :id 

  belongs_to :side
  belongs_to :unified_card,
    :primary_key => :id,
    :foreign_key => :card_id
  belongs_to :card
  belongs_to :card_set
  has_one :faction, :through => :card
  has_one :card_cycle, :through => :card_set
  has_one :side, :through => :card
  has_many :illustrator_printings, primary_key: :id, foreign_key: :printing_id
  has_many :illustrators, :through => :illustrator_printings

  has_many :unified_restrictions, primary_key: :card_id, foreign_key: :card_id
  has_many :card_pool_cards, primary_key: :card_id, foreign_key: :card_id
  has_many :card_pools, :through => :card_pool_cards
end

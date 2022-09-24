# frozen_string_literal: true

class Card < ApplicationRecord
  belongs_to :side
  belongs_to :faction
  belongs_to :card_type
  has_many :card_card_subtypes
  has_many :card_subtypes, :through => :card_card_subtypes
  has_many :printings
  has_many :card_pool_cards
  has_many :card_pools, :through => :card_pool_cards
  has_many :restriction_card_banned
  has_many :restrictions, :through => :restriction_card_banned

  has_many :unified_restrictions

  validates :name, uniqueness: true

  def advancement_requirement
    self[:advancement_requirement] == -1 ? 'X' : self[:advancement_requirement]
  end
   def link_provided
    self[:link_provided] == -1 ? 'X' : self[:link_provided]
  end
  def mu_provided
    self[:mu_provided] == -1 ? 'X' : self[:mu_provided]
  end
  def num_printed_subroutines
    self[:num_printed_subroutines] == -1 ? 'X' : self[:num_printed_subroutines]
  end
  def recurring_credits_provided
    self[:recurring_credits_provided] == -1 ? 'X' : self[:recurring_credits_provided]
  end
end

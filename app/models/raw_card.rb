# frozen_string_literal: true

# This is a simple model object to hold the direct imports from the JSON only.
class RawCard < ApplicationRecord
  self.table_name = 'cards'

  belongs_to :side
  belongs_to :faction
  belongs_to :card_type
  has_many :card_card_subtypes, foreign_key: :card_id, primary_key: :id
  has_many :card_subtypes, :through => :card_card_subtypes
  has_many :printings, foreign_key: :card_id, primary_key: :id
  has_many :unified_printings
  has_many :card_pool_cards
  has_many :card_pools, :through => :card_pool_cards
  has_many :restriction_card_banned
  has_many :restriction_card_global_penalty
  has_many :restriction_card_points, class_name: 'RestrictionCardPoints'
  has_many :restriction_card_restricted
  has_many :restriction_card_universal_faction_cost
  # This is here to support restrictions, but isn't usable on it's own.
  has_many :unified_restrictions
  # Will be all restrictions that directly reference this card in any way.
  has_many :restrictions, -> { where('unified_restrictions.in_restriction': true) }, :through => :unified_restrictions

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

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

  validates :name, uniqueness: true
end

# frozen_string_literal: true

class Restriction < ApplicationRecord
  has_many :snapshots

  has_one :restriction_card_banned
  has_many :banned_cards, :through => :restriction_card_banned, :source => :card

  has_one :restriction_card_restricted
  has_many :restricted_cards, :through => :restriction_card_restricted, :source => :card

  has_one :restriction_card_universal_faction_cost
  has_many :universal_faction_cost_cards, :through => :restriction_card_universal_faction_cost, :source => :card

  has_one :restriction_card_global_penalty
  has_many :global_penalty_cards, :through => :restriction_card_global_penalty, :source => :card

  has_one :restriction_card_points
  has_many :points_cards, :through => :restriction_card_points, :source => :card

  has_one :restriction_card_subtype_banned
  has_many :banned_subtypes, :through => :restriction_card_subtype_banned, :source => :card_subtype

  validates :name, uniqueness: true
end

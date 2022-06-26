# frozen_string_literal: true

class Restriction < ApplicationRecord
  has_many :restriction_cards
  has_many :cards, :through => :restriction_cards
  has_many :restriction_subtypes
  has_many :card_subtypes, :through => :restriction_subtypes
  has_many :snapshots

  validates :name, uniqueness: true
end

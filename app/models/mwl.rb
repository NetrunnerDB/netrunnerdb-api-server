# frozen_string_literal: true

class Mwl < ApplicationRecord
  has_many :mwl_cards
  has_many :cards, :through => :mwl_cards
  has_many :mwl_subtypes
  has_many :subtypes, :through => :mwl_subtypes
  has_many :snapshots

  validates :name, uniqueness: true
end

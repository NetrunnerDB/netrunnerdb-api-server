# frozen_string_literal: true

class CardPool < ApplicationRecord
  has_many :card_pool_card_cycles
  has_many :card_cycles, through: :card_pool_card_cycles
  has_many :card_pool_card_sets
  has_many :card_sets, through: :card_pool_card_sets
  has_many :card_pool_cards
  has_many :raw_cards, through: :card_pool_cards
  has_many :cards, through: :card_pool_cards, primary_key: :card_id, foreign_key: :id
  has_many :snapshots

  belongs_to :format

  def num_cards
    cards.size
  end

  validates :name, uniqueness: true
end

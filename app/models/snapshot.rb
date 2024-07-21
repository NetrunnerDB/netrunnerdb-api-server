# frozen_string_literal: true

# Model for Snapshot objects.
class Snapshot < ApplicationRecord
  belongs_to :format
  belongs_to :card_pool
  belongs_to :restriction, optional: true
  has_many :card_cycles, through: :card_pool
  has_many :card_sets, through: :card_pool
  has_many :cards, through: :card_pool

  # TODO(plural): Convert date_start to a real date field.
  def num_cards
    cards.length
  end
end

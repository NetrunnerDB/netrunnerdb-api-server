# frozen_string_literal: true

# Model for reviews of cards.
class Review < ApplicationRecord
  belongs_to :card
  has_many :review_comments
  has_many :review_votes

  def votes
    review_votes.count
  end

  def comments
    review_comments
  end
end

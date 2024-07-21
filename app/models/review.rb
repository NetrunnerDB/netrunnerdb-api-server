class Review < ApplicationRecord
  belongs_to :card
  has_many :review_comments
  has_many :review_votes
  belongs_to :user

  def votes
    review_votes.count
  end

  def comments
    review_comments
  end
end

# frozen_string_literal: true

# Model for votes on reviews.
class ReviewVote < ApplicationRecord
  belongs_to :review
end

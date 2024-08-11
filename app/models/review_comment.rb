# frozen_string_literal: true

# Model for comments on reviews.
class ReviewComment < ApplicationRecord
  belongs_to :review
end

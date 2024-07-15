# frozen_string_literal: true

class ReviewCommentResource < ApplicationResource
  primary_endpoint '/review_comments', %i[index show]
  self.model = ReviewComment

  attribute :id, :string
  attribute :username, :string
  attribute :body, :string
  attribute :review_id, :string, only: [:filterable]
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  belongs_to :review
end

# frozen_string_literal: true

class ReviewResource < ApplicationResource
  primary_endpoint '/reviews', %i[index show]

  self.model = Review

  attribute :id, :string
  attribute :username, :string
  attribute :body, :string
  attribute :card, :string do
    @object.card.title
  end
  attribute :card_id, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :votes, :integer

  belongs_to :card

  attribute :comments, :array do
    @object.comments.map do |comment|
      {
        id: comment.id,
        body: comment.body,
        user: comment.username,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      }
    end
  end
  # has_many :comments, resource: ReviewCommentResource
end

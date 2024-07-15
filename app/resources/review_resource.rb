# frozen_string_literal: true

class ReviewResource < ApplicationResource
  primary_endpoint '/reviews', %i[index show]

  self.model = Review

  attribute :id, :string
  attribute :username, :string
  attribute :ruling, :string
  attribute :card, :string do
    @object.card.title
  end
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :votes, :integer

  filter :card, :string do
    eq do |scope, value|
      card = Card.find(value) # N+1?
      scope.where(card:)
    end
  end

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

# frozen_string_literal: true

class ReviewResource < ApplicationResource
  primary_endpoint '/resources', %i[index show]

  self.model = Review

  attribute :id, :string
  attribute :username, :string
  attribute :card, :string do
    @object.card.title
  end
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :votes, :integer
end

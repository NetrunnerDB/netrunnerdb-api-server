# frozen_string_literal: true

# Controller for the Review resource.
class ReviewsController < ApplicationController
  def index
    add_total_stat(params)
    base_scope = Review.includes(:card, :review_comments, :review_votes)
    reviews = ReviewResource.all(params, base_scope)
    respond_with(reviews)
  end

  def show
    reviews = ReviewResource.find(params)
    respond_with(reviews)
  end
end

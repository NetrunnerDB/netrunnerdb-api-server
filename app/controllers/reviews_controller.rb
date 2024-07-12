# frozen_string_literal: true

# Controller for the Review resource.
class ReviewsController < ApplicationController
  def index
    reviews = ReviewResource.all(params)
    respond_with(reviews)
  end

  def show
    reviews = ReviewResource.find(params)
    respond_with(reviews)
  end
end

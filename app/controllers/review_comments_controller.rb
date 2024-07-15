# frozen_string_literal: true

# Controller for the Review Comment resource.
class ReviewCommentsController < ApplicationController
  def index
    comments = ReviewCommentResource.all(params)
    respond_with(comments)
  end

  def show
    comments = ReviewCommentResource.find(params)
    respond_with(comments)
  end
end

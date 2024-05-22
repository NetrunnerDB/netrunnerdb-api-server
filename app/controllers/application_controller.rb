# frozen_string_literal: true

# Base controller for NRDB API Resources.
class ApplicationController < ActionController::API
  include Graphiti::Rails::Responders

  # Graphiti supports .json and .xml formats in addition to JSON::API. We only allow JSON::API responses.
  def index
    unless request.format.jsonapi?
      render plain: 'Requested format %s is not acceptable.' % request.format, status: :not_acceptable
      return false
    end
    true
  end

  def show
    unless request.format.jsonapi?
      render plain: 'Requested format %s is not acceptable.' % request.format, status: :not_acceptable
      return false
    end
    true
  end
end

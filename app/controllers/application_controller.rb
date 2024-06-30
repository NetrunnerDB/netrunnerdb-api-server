# frozen_string_literal: true

# Base controller for NRDB API Resources.
class ApplicationController < ActionController::API
  include Graphiti::Rails::Responders

  class UnauthenticatedError < StandardError; end
  class UnauthorizedError < StandardError; end

  register_exception UnauthenticatedError, status: 401
  register_exception UnauthorizedError, status: 403
end

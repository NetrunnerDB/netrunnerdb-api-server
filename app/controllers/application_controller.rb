# frozen_string_literal: true

# Base controller for NRDB API Resources.
class ApplicationController < ActionController::API
  include Graphiti::Rails::Responders

  class BadDeckError < StandardError; end
  class UnauthenticatedError < StandardError; end
  class UnauthorizedError < StandardError; end

  register_exception BadDeckError, status: 400
  register_exception UnauthorizedError, status: 403
  register_exception UnauthorizedError, status: 403

  def add_total_stat(params)
    params['stats'] = {} unless params.include?('stats')
    params['stats']['total'] = 'count'
  end
end

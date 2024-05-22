# frozen_string_literal: true

# Base controller for NRDB API Resources.
class ApplicationController < ActionController::API
  include Graphiti::Rails::Responders
end

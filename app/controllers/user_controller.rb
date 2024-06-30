# frozen_string_literal: true

# Controller for the private User resource, will force this to only return the current user.
class UserController < ApplicationController
  include JwtAuthorizationConcern
  def index
    user = UserResource.find({ id: current_user.id })
    respond_with(user)
  end
end

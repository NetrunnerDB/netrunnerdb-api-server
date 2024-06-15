# frozen_string_literal: true

# Controller for the Snapshot resource.
class UserController < ApplicationController
    def index
      include JwtAuthorizationConcern
    end
end

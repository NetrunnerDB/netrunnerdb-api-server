# frozen_string_literal: true

# Private resource for the User objects.
class UserResource < ApplicationResource
  attribute :id, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
end

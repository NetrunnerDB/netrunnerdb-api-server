# frozen_string_literal: true

# Model for User objects.
#
# This object will remain fairly lean since user management will not be handled in the application itself.
class User < ApplicationRecord
  has_many :decks
end

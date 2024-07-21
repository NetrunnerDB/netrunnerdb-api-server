# frozen_string_literal: true

# Model for Ruling objects.
class Ruling < ApplicationRecord
  belongs_to :card
end

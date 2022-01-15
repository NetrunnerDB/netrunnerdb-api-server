# frozen_string_literal: true

class CardSubtypes < ApplicationRecord
  belongs_to :cards
  belongs_to :subtypes
end

# frozen_string_literal: true

class Legality < ApplicationRecord
  belongs_to :legality_type
  belongs_to :deck_format
  belongs_to :card
end

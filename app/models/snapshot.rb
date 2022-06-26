# frozen_string_literal: true

class Snapshot < ApplicationRecord
  belongs_to :format
  belongs_to :card_pool
  belongs_to :restriction
end

# frozen_string_literal: true

class Snapshot < ApplicationRecord
  belongs_to :format
  belongs_to :card_pool
  belongs_to :restriction, optional: :true
  has_many :cards, through: :card_pool
end

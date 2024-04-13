class Decklist < ApplicationRecord
  has_many :decklist_cards, dependent: :destroy
  has_many :cards, :through => :decklist_cards
end

class Decklist < ApplicationRecord
  has_one :identity_card, :class_name => 'Card', :foreign_key => 'id', :primary_key => 'identity_card_id'
  belongs_to :side

  has_many :decklist_cards, dependent: :destroy
  has_many :cards, :through => :decklist_cards
end

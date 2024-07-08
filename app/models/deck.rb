class Deck < ApplicationRecord
  belongs_to :user
  belongs_to :side

  has_one :identity_card,
          class_name: 'Card',
          foreign_key: 'id',
          primary_key: 'identity_card_id'

  delegate :faction_id, to: :identity_card
  scope :by_faction, lambda { |faction_id|
    joins(:identity_card).where(unified_cards: { faction_id: faction_id })
  }
  has_one :faction, through: :identity_card

  has_many :deck_cards
  has_many :cards, through: :deck_cards
end

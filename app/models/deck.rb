class Deck < ApplicationRecord
  belongs_to :user
  belongs_to :side

  has_one :identity_card,
          class_name: 'UnifiedCard',
          foreign_key: 'id',
          primary_key: 'identity_card_id'

  has_many :card_slots, class_name: 'DeckCard'
  has_many :cards, class_name: 'UnifiedCard', through: :card_slots

  delegate :faction_id, to: :identity_card
  scope :by_faction, lambda { |faction_id|
    joins(:identity_card).where(unified_cards: { faction_id: faction_id })
  }
  has_one :faction, through: :identity_card
end

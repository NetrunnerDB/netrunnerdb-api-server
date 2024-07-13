class Decklist < ApplicationRecord
  # TODO(plural): Add a relationship to a public user object.
  belongs_to :side

  has_one :identity_card,
          class_name: 'Card',
          foreign_key: 'id',
          primary_key: 'identity_card_id'

  delegate :faction_id, to: :identity_card
  scope :by_faction, lambda { |faction_id|
    # unified_cards is the table name, not the model name here in the where clause
    joins(:identity_card).where(unified_cards: { faction_id: })
  }
  has_one :faction, through: :identity_card

  has_many :decklist_cards
  has_many :cards, through: :decklist_cards
end

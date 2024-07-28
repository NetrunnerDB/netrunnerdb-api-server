# frozen_string_literal: true

# Model for Decklist objects.
#
# Decklists are the public, published decklists owned by various users.
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

  def card_slots
    decklist_cards.order(:card_id).each_with_object({}) { |c, h| h[c.card_id] = c.quantity }
  end

  def num_cards
    decklist_cards
      # Exclude identity
      .reject { |c| c.card_id == identity_card_id }
      .map(&:quantity).sum
  end

  # TODO(plural): Extract this out to share between public and private decklists.
  # This is the basic definition, but does not take restriction modifications
  # into account. Leaving this here as an example for now, but it will need to
  # be removed in favor of snapshot-specific calculations.
  def influence_spent
    qty = decklist_cards.each_with_object({}) { |c, h| h[c.card_id] = c.quantity }
    cards
      # Exclude identity
      .reject { |c| c.id == identity_card.id }
      .filter { |c| c.faction_id != identity_card.faction_id }
      .map { |c| c.influence_cost.nil? ? 0 : (c.influence_cost * qty[c.id]) }
      .sum
  end
end

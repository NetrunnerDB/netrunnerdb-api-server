# frozen_string_literal: true

# Public resource for CardCycle objects.
class DecklistResource < ApplicationResource
  primary_endpoint '/decklists', %i[index show]

  attribute :id, :uuid
  attribute :user_id, :string
  attribute :follows_basic_deckbuilding_rules, :boolean
  attribute :identity_card_id, :string
  attribute :name, :string
  attribute :notes, :string
  attribute :tags, :array_of_strings
  attribute :side_id, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  attribute :faction_id, :string do
    id = Card.find(@object.identity_card_id)
    id&.faction_id
  end

  attribute :card_slots, :hash do
    Rails.logger.error 'asdf'
    cards = {}
    @object.decklist_cards.each do |c|
      cards[c.card_id] = c.quantity
    end
    cards
  end

  attribute :num_cards, :integer do
    @object.decklist_cards.map(&:quantity).sum
  end

  # This is the basic definition, but does not take restriction modifications
  # into account. Leaving this here as an example for now, but it will need to
  # be removed in favor of snapshot-specific calculations.
  attribute :influence_spent, :integer do
    qty = {}
    @object.decklist_cards.each do |c|
      qty[c.card_id] = c.quantity
    end
    Rails.logger.info format('qty is %s', qty.inspect)
    id = Card.find(@object.identity_card_id)
    @object.cards
           .filter { |c| c.faction_id != id.faction_id }
           .map { |c| c.influence_cost.nil? ? 0 : (c.influence_cost * qty[c.id]) }
           .sum
  end

  belongs_to :side
  belongs_to :faction do
    link do |decklist|
      helpers = Rails.application.routes.url_helpers
      helpers.factions_url(params: { filter: { id: decklist.faction_id } })
    end
  end

  belongs_to :identity_card, resource: CardResource do #, foreign_key: :identity_card_id do
    link do |decklist|
      helpers = Rails.application.routes.url_helpers
      helpers.cards_url(params: { filter: { id: decklist.identity_card_id } })
    end
  end

  many_to_many :cards
end

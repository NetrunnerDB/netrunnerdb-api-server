# frozen_string_literal: true

# Public resource for Decklist objects.
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

  attribute :faction_id, :string, filterable: true do
    id = Card.find(@object.identity_card_id)
    id&.faction_id
  end

  filter :faction_id, :string do
    eq do |scope, value|
      scope.by_faction(value)
    end
  end

  attribute :card_slots, :hash do
    cards = {}
    @object.card_slots.order(:card_id).each do |c|
      cards[c.card_id] = c.quantity
    end
    cards
  end

  attribute :num_cards, :integer do
    @object.card_slots.map(&:quantity).sum
  end

  # This is the basic definition, but does not take restriction modifications
  # into account. Leaving this here as an example for now, but it will need to
  # be removed in favor of snapshot-specific calculations.
  attribute :influence_spent, :integer do
    qty = {}
    @object.card_slots.each do |c|
      qty[c.card_id] = c.quantity
    end
    id = Card.find(@object.identity_card_id)
    @object.cards
           .filter { |c| c.faction_id != id.faction_id }
           .map { |c| c.influence_cost.nil? ? 0 : (c.influence_cost * qty[c.id]) }
           .sum
  end

  belongs_to :side

  # The rubocop warning is disabled because this relationship won't work without the foreign_key
  # explicitly set, presumably because this is a delegated field on the model.
  belongs_to :faction, foreign_key: :faction_id do # rubocop:disable Rails/RedundantForeignKey
    link do |decklist|
      '%s/%s' % [ Rails.application.routes.url_helpers.factions_url, decklist.faction_id ]
    end
  end

  # The rubocop warning is disabled because this relationship won't work
  # without it because there is no identity_card table.
  belongs_to :identity_card, resource: CardResource, foreign_key: :identity_card_id do # rubocop:disable Rails/RedundantForeignKey
    link do |decklist|
      '%s/%s' % [ Rails.application.routes.url_helpers.cards_url, decklist.identity_card_id ]
    end
  end

  # TODO(plural): Fix cards relationship
  # has_many :cards
end

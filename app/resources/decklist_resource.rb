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

  # Will return decklists where all cards specified are present.
  filter :card_id, :string do
    eq do |scope, card_ids|
      scope.joins(:decklist_cards)
           .where(decklist_cards: { card_id: card_ids })
           .group('decklists.id')
           .having('COUNT(DISTINCT decklist_cards.card_id) = ?', card_ids.length)
    end
  end

  attribute :card_slots, :hash
  attribute :num_cards, :integer
  attribute :influence_spent, :integer

  belongs_to :side

  # The rubocop warning is disabled because this relationship won't work without the foreign_key
  # explicitly set, presumably because this is a delegated field on the model.
  belongs_to :faction, foreign_key: :faction_id do # rubocop:disable Rails/RedundantForeignKey
    link do |decklist|
      format('%s/%s', Rails.application.routes.url_helpers.factions_url, decklist.faction_id)
    end
  end

  # The rubocop warning is disabled because this relationship won't work
  # without it because there is no identity_card table.
  belongs_to :identity_card, resource: CardResource, foreign_key: :identity_card_id do # rubocop:disable Rails/RedundantForeignKey
    link do |decklist|
      format('%s/%s', Rails.application.routes.url_helpers.cards_url, decklist.identity_card_id)
    end
  end

  many_to_many :cards
end

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

  # Will return decklists that do NOT contain any of the specified cards.
  filter :exclude_card_id, :string do
    eq do |scope, card_ids|
      scope.left_joins(:decklist_cards)
           .group('decklists.id')
           .having('COUNT(CASE WHEN decklists_cards.card_id IN (?) THEN 1 END) = 0', card_ids)
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
      format('%<url>s/%<id>s', url: Rails.application.routes.url_helpers.factions_url, id: decklist.faction_id)
    end
  end

  many_to_many :cards
end

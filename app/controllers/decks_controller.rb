# frozen_string_literal: true

# Controller for the Deck resource.
class DecksController < ApplicationController
  include JwtAuthorizationConcern

  def index
    base_scope = Deck.where(user_id: @current_user.id)
    params[:filter].delete(:user_id) if params.include?(:filter)
    decks = DeckResource.all(params, base_scope)
    respond_with(decks)
  end

  def show
    deck = DeckResource.find(params)
    respond_with(deck)
  end

  def create
    # Use the incoming parameters, but build the actual object against the model directly.

    new_deck = Deck.new
    new_deck.user = current_user
    attributes = params[:data][:attributes]
    card_slots = params[:data][:attributes].delete(:card_slots)
    new_deck.name = attributes[:name]
    new_deck.follows_basic_deckbuilding_rules = attributes[:follows_basic_deckbuilding_rules]
    new_deck.identity_card_id = attributes[:identity_card_id]
    new_deck.side_id = attributes[:side_id]
    new_deck.notes = attributes[:notes]
    new_deck.tags = attributes[:tags]

    # TODO(plural): Flesh out nice error messages.
    raise ApplicationController::BadDeckError, 'There was an error creating your deck.' unless new_deck.save

    card_slots.each do |card_id, quantity|
      new_deck.card_slots.create(card_id:, quantity:)
    end

    simplified_params = {data: { id: new_deck.id, type: 'decks' } }
    deck = DeckResource.find(simplified_params)
    render jsonapi: deck, status: 201
  end

  def update
    attributes = params[:data][:attributes]
    attributes.delete(:faction_id)
    card_slots = attributes.delete(:card_slots)
    deck_resource = DeckResource.find(params)

    ActiveRecord::Base.transaction do
      DeckCard.where(deck_id: deck_resource.data.id).delete_all

      deck = Deck.find(deck_resource.data.id)

      deck.identity_card_id = attributes.key?(:identity_card_id) ? attributes[:identity_card_id] : deck.identity_card_id
      deck.side_id = attributes.has_key?(:side_id) ? attributes[:side_id] : deck.side_id
      deck.follows_basic_deckbuilding_rules = attributes.key?(:follows_basic_deckbuilding_rules) ?
          attributes[:follows_basic_deckbuilding_rules] : deck.follows_basic_deckbuilding_rules
      deck.name = attributes.has_key?(:name) ? attributes[:name] : deck.name
      deck.notes = attributes.has_key?(:notes) ? attributes[:notes] : deck.notes
      deck.tags = attributes.has_key?(:tags) ? attributes[:tags] : deck.tags
      deck.updated_at = Time.now.utc.to_formatted_s(:iso8601)

      card_slots.each do |card_id, quantity|
        deck.card_slots.create!(card_id:, quantity:)
      end

      deck.save!
    rescue ActiveRecord::RecordInvalid => e
      raise ApplicationController::BadDeckError, "There was an error updating your deck: #{e.message}"
    end

    deck_resource = DeckResource.find(params)

    render jsonapi: deck_resource
  end

  def destroy
    deck = DeckResource.find(params)

    if deck.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: deck
    end
  end
end

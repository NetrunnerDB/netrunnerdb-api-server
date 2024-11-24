# frozen_string_literal: true

# Controller for the decklist resource.
class DecklistsController < ApplicationController
  def index
    add_total_stat(params)
    base_scope = Decklist.includes(:identity_card, :cards)
    decklists = DecklistResource.all(params, base_scope)
    respond_with(decklists)
  end

  def show
    decklist = DecklistResource.find(params)
    respond_with(decklist)
  end
end

# frozen_string_literal: true

# Controller for the decklist resource.
class DecklistsController < ApplicationController
  def index
    decklists = DecklistResource.all(params)
    respond_with(decklists)
  end

  def show
    decklist = DecklistResource.find(params)
    respond_with(decklist)
  end
end

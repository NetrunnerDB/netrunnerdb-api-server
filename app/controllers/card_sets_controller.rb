# frozen_string_literal: true

# Controller for the CardSet resource.
class CardSetsController < ApplicationController
  def index
    super or return
    card_sets = CardSetResource.all(params)
    respond_with(card_sets)
  end

  def show
    super or return
    card_set = CardSetResource.find(params)
    respond_with(card_set)
  end
end

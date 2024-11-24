# frozen_string_literal: true

# Controller for the CardType resource.
class CardTypesController < ApplicationController
  def index
    add_total_stat(params)
    card_types = CardTypeResource.all(params)
    respond_with(card_types)
  end

  def show
    side = CardTypeResource.find(params)
    respond_with(side)
  end
end

# frozen_string_literal: true

# Controller for the Card resource.
class CardsController < ApplicationController
  def index
    add_total_stat(params)
    cards = CardResource.all(params)
    debugger
    respond_with(cards)
  end

  def show
    card = CardResource.find(params)
    respond_with(card)
  end
end

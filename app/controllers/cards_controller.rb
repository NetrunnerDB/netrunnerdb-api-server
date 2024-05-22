# frozen_string_literal: true

# Controller for the Card resource.
class CardsController < ApplicationController
  def index
    super or return
    cards = CardResource.all(params)
    respond_with(cards)
  end

  def show
    super or return
    card = CardResource.find(params)
    respond_with(card)
  end
end

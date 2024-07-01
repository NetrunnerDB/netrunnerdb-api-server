# frozen_string_literal: true

# Controller for the CardPool resource.
class CardPoolsController < ApplicationController
  def index
    card_pools = CardPoolResource.all(params)
    respond_with(card_pools)
  end

  def show
    card_pool = CardPoolResource.find(params)
    respond_with(card_pool)
  end
end

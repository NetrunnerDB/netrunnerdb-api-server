# frozen_string_literal: true

# Controller for the CardPool resource.
class CardPoolsController < ApplicationController
  def index
    add_total_stat(params)
    base_scope = CardPool.includes(:cards)
    card_pools = CardPoolResource.all(params, base_scope)
    respond_with(card_pools)
  end

  def show
    card_pool = CardPoolResource.find(params)
    respond_with(card_pool)
  end
end

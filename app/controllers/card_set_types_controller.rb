# frozen_string_literal: true

# Controller for the CardSetType resource.
class CardSetTypesController < ApplicationController
  def index
    add_total_stat(params)
    card_set_types = CardSetTypeResource.all(params)
    respond_with(card_set_types)
  end

  def show
    card_set_type = CardSetTypeResource.find(params)
    respond_with(card_set_type)
  end
end

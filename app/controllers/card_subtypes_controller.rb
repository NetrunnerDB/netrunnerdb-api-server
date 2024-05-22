# frozen_string_literal: true

# Controller for the CardSubtype resource.
class CardSubtypesController < ApplicationController
  def index
    super or return
    card_subtypes = CardSubtypeResource.all(params)
    respond_with(card_subtypes)
  end

  def show
    super or return
    card_subtype = CardSubtypeResource.find(params)
    respond_with(card_subtype)
  end
end

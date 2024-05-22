# frozen_string_literal: true

# Controller for the CardCycle resource.
class CardCyclesController < ApplicationController
  def index
    super or return
    card_cycles = CardCycleResource.all(params)
    respond_with(card_cycles)
  end

  def show
    super or return
    card_cycle = CardCycleResource.find(params)
    respond_with(card_cycle)
  end
end

# frozen_string_literal: true

# Controller for the Faction resource.
class FactionsController < ApplicationController
  def index
    super or return
    factions = FactionResource.all(params)
    respond_with(factions)
  end

  def show
    super or return
    faction = FactionResource.find(params)
    respond_with(faction)
  end
end

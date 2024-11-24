# frozen_string_literal: true

# Controller for the Faction resource.
class FactionsController < ApplicationController
  def index
    add_total_stat(params)
    factions = FactionResource.all(params)
    respond_with(factions)
  end

  def show
    faction = FactionResource.find(params)
    respond_with(faction)
  end
end

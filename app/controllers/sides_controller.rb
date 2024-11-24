# frozen_string_literal: true

# Controller for the Side resource.
class SidesController < ApplicationController
  def index
    add_total_stat(params)
    sides = SideResource.all(params)

    respond_with(sides)
  end

  def show
    side = SideResource.find(params)
    respond_with(side)
  end
end

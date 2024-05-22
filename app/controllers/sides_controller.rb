# frozen_string_literal: true

# Controller for the Side resource.
class SidesController < ApplicationController
  def index
    super or return
    sides = SideResource.all(params)

    respond_with(sides)
  end

  def show
    super or return
    side = SideResource.find(params)
    respond_with(side)
  end
end

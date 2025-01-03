# frozen_string_literal: true

# Controller for the Ruling resource.
class RulingsController < ApplicationController
  def index
    add_total_stat(params)
    rulings = RulingResource.all(params)

    respond_with(rulings)
  end

  def show
    ruling = RulingResource.find(params)
    respond_with(ruling)
  end
end

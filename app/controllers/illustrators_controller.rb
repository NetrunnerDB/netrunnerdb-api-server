# frozen_string_literal: true

# Controller for the Illustrator resource.
class IllustratorsController < ApplicationController
  def index
    add_total_stat(params)
    illustrators = IllustratorResource.all(params)
    respond_with(illustrators)
  end

  def show
    format = IllustratorResource.find(params)
    respond_with(format)
  end
end

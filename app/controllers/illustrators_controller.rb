# frozen_string_literal: true

# Controller for the Illustrator resource.
class IllustratorsController < ApplicationController
  def index
    add_total_stat(params)
    base_scope = Illustrator
    if params.include?('include') && params[:include].include?('printings')
      base_scope = Illustrator.includes(%i[printings])
    end
    illustrators = IllustratorResource.all(params, base_scope)
    respond_with(illustrators)
  end

  def show
    format = IllustratorResource.find(params)
    respond_with(format)
  end
end

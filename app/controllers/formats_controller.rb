# frozen_string_literal: true

# Controller for the Format resource.
class FormatsController < ApplicationController
  def index
    add_total_stat(params)
    base_scope = Format.includes(:restrictions, :snapshots)
    formats = FormatResource.all(params, base_scope)
    respond_with(formats)
  end

  def show
    base_scope = Format.includes(:restrictions, :snapshots)
    format = FormatResource.find(params, base_scope)
    respond_with(format)
  end
end

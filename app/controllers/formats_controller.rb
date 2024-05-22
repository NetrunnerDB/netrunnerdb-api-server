# frozen_string_literal: true

# Controller for the Format resource.
class FormatsController < ApplicationController
  def index
    formats = FormatResource.all(params)
    respond_with(formats)
  end

  def show
    format = FormatResource.find(params)
    respond_with(format)
  end
end

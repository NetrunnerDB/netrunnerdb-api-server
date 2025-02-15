# frozen_string_literal: true

# Controller for the Printing resource.
class PrintingsController < ApplicationController
  def index
    add_total_stat(params)
    # printings = PrintingResource.all(params)

    respond_with(PrintingResource.all(params))
  end

  def show
    printing = PrintingResource.find(params)
    respond_with(printing)
  end
end

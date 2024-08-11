# frozen_string_literal: true

class AddNumPrintingsToIllustrators < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :illustrators, :num_printings, :integer
  end
end

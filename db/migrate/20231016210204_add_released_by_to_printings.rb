# frozen_string_literal: true

class AddReleasedByToPrintings < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :printings, :released_by, :string
  end
end

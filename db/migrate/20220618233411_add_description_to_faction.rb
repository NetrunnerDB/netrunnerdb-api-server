# frozen_string_literal: true

class AddDescriptionToFaction < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :factions, :description, :string
  end
end

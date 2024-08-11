# frozen_string_literal: true

class AddDesignedByToCards < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :cards, :designed_by, :string
  end
end

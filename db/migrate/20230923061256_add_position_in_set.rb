# frozen_string_literal: true

class AddPositionInSet < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :printings, :position_in_set, :int
  end
end

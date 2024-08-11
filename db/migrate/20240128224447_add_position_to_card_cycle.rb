# frozen_string_literal: true

class AddPositionToCardCycle < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :card_cycles, :position, :integer
  end
end

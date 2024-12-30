# frozen_string_literal: true

class AddLayoutIdToCards < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    add_column :cards, :layout_id, :string, default: 'normal', null: false
  end
end

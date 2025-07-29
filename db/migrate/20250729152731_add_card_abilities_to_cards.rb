# frozen_string_literal: true

class AddCardAbilitiesToCards < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :cards, :install_effect, :bool, default: false
    add_column :cards, :charge, :bool, default: false
    add_column :cards, :has_gain_click, :bool, default: false
    add_column :cards, :has_paid_ability, :bool, default: false
    add_column :cards, :mark, :bool, default: false
    add_column :cards, :sabotage, :bool, default: false
    add_column :cards, :score_effect, :bool, default: false
    add_column :cards, :steal_effect, :bool, default: false
  end
end 
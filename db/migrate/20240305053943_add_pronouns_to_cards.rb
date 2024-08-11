# frozen_string_literal: true

class AddPronounsToCards < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    add_column :cards, :pronouns, :string
  end
end

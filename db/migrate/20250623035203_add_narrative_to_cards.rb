# frozen_string_literal: true

class AddNarrativeToCards < ActiveRecord::Migration[7.2] # rubocop:disable Style/Documentation
  def change
    add_column :cards, :narrative_text, :string
  end
end

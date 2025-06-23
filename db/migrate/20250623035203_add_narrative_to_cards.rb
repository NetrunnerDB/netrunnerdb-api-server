# frozen_string_literal: true

class AddNarrativeToCards < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :narrative_text, :string
  end
end

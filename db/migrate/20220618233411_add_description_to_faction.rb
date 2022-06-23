class AddDescriptionToFaction < ActiveRecord::Migration[7.0]
  def change
    add_column :factions, :description, :string
  end
end

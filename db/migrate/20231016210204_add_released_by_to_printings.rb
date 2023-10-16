class AddReleasedByToPrintings < ActiveRecord::Migration[7.0]
  def change
    add_column :printings, :released_by, :string
  end
end

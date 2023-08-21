class AddFormatToRestrictions < ActiveRecord::Migration[7.0]
  def change
    add_column :restrictions, :format_id, :string
    add_foreign_key :restrictions, :formats
  end
end

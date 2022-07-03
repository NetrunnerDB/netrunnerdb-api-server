class RenamePrintingIllustrator < ActiveRecord::Migration[7.0]
  def change
    rename_column :printings, :illustrator, :display_illustrators
  end
end

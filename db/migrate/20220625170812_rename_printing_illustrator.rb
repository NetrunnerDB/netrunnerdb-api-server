# frozen_string_literal: true

class RenamePrintingIllustrator < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    rename_column :printings, :illustrator, :display_illustrators
  end
end

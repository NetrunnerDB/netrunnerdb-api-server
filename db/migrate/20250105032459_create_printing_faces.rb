# frozen_string_literal: true

class CreatePrintingFaces < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    create_table :printing_faces, primary_key: %i[printing_id face_index] do |t|
      t.string :printing_id, null: false
      t.integer :face_index, null: false
      t.integer :copy_quantity
      t.text :flavor
      t.timestamps
    end
  end
end

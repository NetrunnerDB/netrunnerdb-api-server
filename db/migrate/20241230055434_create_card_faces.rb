class CreateCardFaces < ActiveRecord::Migration[7.1]
  def change
    create_table :card_faces, primary_key: %i[card_id face_index] do |t|
      t.string :card_id, null: false
      t.integer :face_index, null: false
      t.text :base_link
      t.text :display_subtypes
      t.text :stripped_text
      t.text :stripped_title
      t.text :text
      t.text :title
      t.timestamps
    end
  end
end

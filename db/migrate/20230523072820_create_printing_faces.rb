class CreatePrintingFaces < ActiveRecord::Migration[7.0]
  def change
    create_table :printing_faces, id: :string do |t|
      t.string :printing_id, null: false
      t.text :flavor
      t.text :display_illustrators
      t.integer :copy_quantity
      t.timestamps
    end

    create_table :printings_printing_faces, id: false, force: :cascade do |t|
      t.string :printing_id, null: false
      t.string :printing_face_id, null: false
      t.index [:printing_id, :printing_face_id], name: "index_printings_printing_faces_on_printing_id_and_face_id", unique: true # shortened name due to limit
    end

    create_table :printing_faces_illustrators, id: false, force: :cascade do |t|
      t.string :printing_face_id, null: false
      t.string :illustrator_id, null: false
      t.index [:printing_face_id, :illustrator_id], name: "index_printing_faces_illustrators_on_face_id_and_illustrator_id", unique: true # shortened name due to limit
    end
  end
end

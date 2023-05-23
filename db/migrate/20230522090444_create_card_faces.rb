class CreateCardFaces < ActiveRecord::Migration[7.0]
  def change
    create_table :card_faces, id: :string do |t|
      t.string :card_id, null: false
      t.text :title
      t.text :stripped_title
      t.text :base_link
      t.integer :advancement_requirement
      t.integer :agenda_points
      t.integer :cost
      t.integer :memory_cost
      t.integer :strength
      t.text :text
      t.text :stripped_text
      t.integer :trash_cost
      t.boolean :is_unique
      t.text :display_subtypes
      t.timestamps
    end

    create_table :cards_card_faces, id: false, force: :cascade do |t|
      t.string :card_id, null: false
      t.string :card_face_id, null: false
      t.index [:card_id, :card_face_id], name: "index_cards_card_faces_on_card_id_and_card_face_id", unique: true
    end

    create_table :card_faces_card_subtypes, id: false, force: :cascade do |t|
      t.string :card_face_id, null: false
      t.string :card_subtype_id, null: false
      t.index [:card_face_id, :card_subtype_id], name: "index_card_faces_card_subtypes_on_face_id_and_subtype_id", unique: true # shortened name due to limit
    end
  end
end

# frozen_string_literal: true

class CreateIllustratorTables < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    create_table :illustrators, id: :string do |t|
      t.string :name
      t.timestamps
    end

    create_table :illustrators_printings, id: false, force: :cascade do |t|
      t.string :illustrator_id, null: false
      t.string :printing_id, null: false
      t.index %i[illustrator_id printing_id], name: 'index_illustrators_printings_on_illustrator_id_and_printing_id',
                                              unique: true
    end
  end
end

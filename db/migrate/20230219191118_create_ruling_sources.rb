class CreateRulingSources < ActiveRecord::Migration[7.0]
  def change
    create_table :ruling_sources, id: :string  do |t|
      t.string :name, null: false
      t.string :url

      t.timestamps
    end
  end
end

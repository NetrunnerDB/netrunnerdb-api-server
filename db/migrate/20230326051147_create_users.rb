class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :string do |t|
      t.timestamps
    end
  end
end

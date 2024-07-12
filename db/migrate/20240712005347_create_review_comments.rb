class CreateReviewComments < ActiveRecord::Migration[7.1]
  def change
    create_table :review_comments do |t|
      t.text :body
      t.string :username
      t.references :review, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class RenameReviewRulingToBody < ActiveRecord::Migration[7.1]
  def change
    change_table :reviews do |t|
      t.rename :ruling, :body
    end
  end
end

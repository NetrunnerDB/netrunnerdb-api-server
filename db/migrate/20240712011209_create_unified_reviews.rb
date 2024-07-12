class CreateUnifiedReviews < ActiveRecord::Migration[7.1]
  def change
    create_view :unified_reviews, materialized: true
  end
end

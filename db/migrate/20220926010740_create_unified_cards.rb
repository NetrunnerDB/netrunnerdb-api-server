class CreateUnifiedCards < ActiveRecord::Migration[7.0]
  def change
    create_view :unified_cards,  materialized: true 
  end
end

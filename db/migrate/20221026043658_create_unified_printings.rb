class CreateUnifiedPrintings < ActiveRecord::Migration[7.0]
  def change
    create_view :unified_printings,  materialized: true
  end
end

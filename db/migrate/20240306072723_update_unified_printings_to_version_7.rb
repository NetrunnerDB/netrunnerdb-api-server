class UpdateUnifiedPrintingsToVersion7 < ActiveRecord::Migration[7.1]
  def change
  
    update_view :unified_printings,
      version: 7,
      revert_to_version: 6,
      materialized: true
  end
end

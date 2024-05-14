class UpdateUnifiedPrintingsToVersion8 < ActiveRecord::Migration[7.1]
  def change
    update_view :unified_printings,
      version: 8,
      revert_to_version: 7,
      materialized: true
  end
end

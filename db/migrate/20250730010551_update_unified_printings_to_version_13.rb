class UpdateUnifiedPrintingsToVersion13 < ActiveRecord::Migration[7.2]
  def change
    update_view :unified_printings,
      version: 13,
      revert_to_version: 12,
      materialized: true
  end
end

class UpdateUnifiedPrintingsToVersion2 < ActiveRecord::Migration[7.0]
  def change
    update_view :unified_printings, materialized: true, version: 2, revert_to_version: 1
  end
end

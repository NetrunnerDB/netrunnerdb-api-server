class UpdateUnifiedRestrictionsToVersion4 < ActiveRecord::Migration[7.0]
  def change
    update_view :unified_restrictions, materialized: true, version: 4, revert_to_version: 3
  end
end

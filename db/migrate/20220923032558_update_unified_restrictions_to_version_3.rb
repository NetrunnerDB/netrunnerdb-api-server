class UpdateUnifiedRestrictionsToVersion3 < ActiveRecord::Migration[7.0]
  def change
    update_view :unified_restrictions, materialized: true, version: 3, revert_to_version: 2

    add_index :unified_restrictions, :in_restriction
  end
end

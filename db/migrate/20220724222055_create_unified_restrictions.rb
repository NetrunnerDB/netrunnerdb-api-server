# frozen_string_literal: true

class CreateUnifiedRestrictions < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    create_view :unified_restrictions, materialized: true

    add_index :unified_restrictions,  :format_id
    add_index :unified_restrictions,  :card_pool_id
    add_index :unified_restrictions,  :snapshot_id
    add_index :unified_restrictions,  :restriction_id
    add_index :unified_restrictions,  :card_id
  end
end

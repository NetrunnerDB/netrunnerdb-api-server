class AddDetailedAttributesToCards < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :additional_cost, :bool, default: false
    add_column :cards, :advanceable, :bool, default: false
    add_column :cards, :gains_subroutines, :bool, default: false
    add_column :cards, :interrupt, :bool, default: false
    add_column :cards, :link_provided, :integer
    add_column :cards, :mu_provided, :integer
    add_column :cards, :num_printed_subroutines, :integer
    add_column :cards, :on_encounter_effect, :bool, default: false
    add_column :cards, :performs_trace, :bool, default: false
    add_column :cards, :provides_link, :bool, default: false
    add_column :cards, :provides_mu, :bool, default: false
    add_column :cards, :provides_recurring_credits, :bool, default: false
    add_column :cards, :recurring_credits_provided, :integer
    add_column :cards, :rez_effect, :bool, default: false
    add_column :cards, :trash_ability, :bool, default: false
  end
end

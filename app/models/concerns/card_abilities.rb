# frozen_string_literal: true

# Module included by Card and Printing to expose common card ability attributes.
module CardAbilities
  extend ActiveSupport::Concern

  included do
    def card_abilities
      {
        additional_cost:,
        advanceable:,
        charge:,
        gains_subroutines:,
        has_gain_click:,
        install_effect:,
        interrupt:,
        link_provided:,
        mark:,
        mu_provided:,
        num_printed_subroutines:,
        on_encounter_effect:,
        performs_trace:,
        recurring_credits_provided:,
        rez_effect:,
        sabotage:,
        score_effect:,
        steal_effect:,
        trash_ability:
      }
    end
  end
end

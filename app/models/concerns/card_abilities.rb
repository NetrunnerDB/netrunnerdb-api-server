module CardAbilities
    extend ActiveSupport::Concern

    included do
        def card_abilities
            {
            additional_cost: self.additional_cost,
            advanceable: self.advanceable,
            gains_subroutines: self.gains_subroutines,
            interrupt: self.interrupt,
            link_provided: self.link_provided,
            mu_provided: self.mu_provided,
            num_printed_subroutines: self.num_printed_subroutines,
            on_encounter_effect: self.on_encounter_effect,
            performs_trace: self.performs_trace,
            recurring_credits_provided: self.recurring_credits_provided,
            rez_effect: self.rez_effect,
            trash_ability: self.trash_ability,
            }
        end
    end
end
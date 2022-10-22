class CardSearchQueryBuilder
    @@parser = CardSearchParser.new
    @@array_keywords = [
        'card_pool',
        'card_subtype',
        'card_subtype_id',
        'eternal_points',
        'format',
        'has_global_penalty',
        'is_banned',
        'is_restricted',
        'printing_id',
        'restriction_id',
        's',
        'snapshot',
        'universal_faction_cost',
    ]
    @@boolean_keywords = [
        'additional_cost',
        'advanceable',
        'b',
        'banlist',
        'gains_subroutines',
        'in_restriction',
        'interrupt',
        'is_unique',
        'on_encounter_effect',
        'performs_trace',
        'trash_ability',
        'u',
    ]
    @@numeric_keywords = [
        'advancement_cost',
        'agenda_points',
        'base_link',
        'cost',
        'g',
        'h',
        'influence_cost',
        'l',
        'link_provided',
        'm',
        'memory_usage',
        'mu_provided',
        'n',
        'num_printed_subroutines',
        'num_printings',
        'o',
        'p',
        'recurring_credits_provided',
        'strength',
        'trash_cost',
        'v',
    ]
    @@string_keywords = [
        '_',
        'card_type',
        'd',
        'f',
        'faction',
        'side',
        't',
        'text',
        'title',
        'x',
    ]
    @@array_operators = {
        ':' => '',
        '!' => 'NOT',
    }
    @@boolean_operators = {
        ':' => '=',
        '!' => '!=',
    }
    @@numeric_operators = {
        ':' => '=',
        '!' => '!=',
        '<' => '<',
        '<=' => '<=',
        '>' => '>',
        '>=' => '>='
    }
    @@string_operators = {
        ':' => 'LIKE',
        '!' => 'NOT LIKE',
    }
    # Add num_printings
    @@term_to_field_map = {
        # format should implicitly use the currently active card pool and restriction lists unless another is specified.
        '_' => 'unified_cards.stripped_title',
        'additional_cost' => 'unified_cards.additional_cost',
        'advanceable' => 'unified_cards.advanceable',
        'advancement_cost' => 'unified_cards.advancement_requirement',
        'agenda_points' => 'unified_cards.agenda_points',
        'base_link' => 'unified_cards.base_link',
        'card_pool' => 'unified_cards.card_pool_ids',
        'card_subtype' => 'unified_cards.lower_card_subtype_names',
        'card_subtype_id' => 'unified_cards.card_subtype_ids',
        'card_type' => 'unified_cards.card_type_id',
        'cost' => 'unified_cards.cost',
        'd' => 'unified_cards.side_id',
        'eternal_points' => 'unified_cards.restrictions_points',
        'f' => 'unified_cards.faction_id',
        'faction' => 'unified_cards.faction_id',
        'format' => 'unified_cards.format_ids',
        'g' => 'unified_cards.advancement_requirement',
        'gains_subroutines' => 'unified_cards.gains_subroutines',
        'h' => 'unified_cards.trash_cost',
        'has_global_penalty' => 'unified_cards.restrictions_global_penalty',
        'in_restriction' => 'unified_cards.in_restriction',
        'influence_cost' => 'unified_cards.influence_cost',
        'interrupt' => 'unified_cards.interrupt',
        'is_banned' => 'unified_cards.restrictions_banned',
        'is_restricted' => 'unified_cards.restrictions_restricted',
        'is_unique' => 'unified_cards.is_unique',
        'l' => 'unified_cards.base_link',
        'link_provided' => 'unified_cards.link_provided',
        'm' => 'unified_cards.memory_cost',
        'memory_usage' => 'unified_cards.memory_cost',
        'mu_provided' => 'unified_cards.mu_provided',
        'n' => 'unified_cards.influence_cost',
        'num_printed_subroutines' => 'unified_cards.num_printed_subroutines',
        'num_printings' => 'unified_cards.num_printings',
        'o' => 'unified_cards.cost',
        'on_encounter_effect' => 'unified_cards.on_encounter_effect',
        'p' => 'unified_cards.strength',
        'performs_trace' => 'unified_cards.performs_trace',
        'printing_id' => 'unified_cards.printing_ids',
        'recurring_credits_provided' => 'unified_cards.recurring_credits_provided',
        'restriction_id' => 'unified_cards.restriction_ids',
        's' => 'unified_cards.lower_card_subtype_names',
        'side' => 'unified_cards.side_id',
        'snapshot' => 'unified_cards.snapshot_ids',
        'strength' => 'unified_cards.strength',
        't' => 'unified_cards.card_type_id',
        'text' => 'unified_cards.stripped_text',
        'title' => 'unified_cards.stripped_title',
        'trash_ability' => 'unified_cards.trash_ability',
        'trash_cost' => 'unified_cards.trash_cost',
        'u' => 'unified_cards.is_unique',
        'universal_faction_cost' => 'unified_cards.restrictions_universal_faction_cost',
        'v' => 'unified_cards.agenda_points',
        'x' => 'unified_cards.stripped_text',
    }

    @@term_to_left_join_map = {
    }

    def initialize(query)
        @query = query
        @parse_error = nil
        @parse_tree = nil
        @left_joins = Set.new
        @where = ''
        @where_values = []
        begin
            @parse_tree = @@parser.parse(@query)
        rescue Parslet::ParseFailed => e
            @parse_error = e
        end
        if @parse_error != nil
            return
        end
        constraints = []
        where = []
        # TODO(plural): build in explicit support for requirements
        #   {is_banned,is_restricted,eternal_points,has_global_penalty,universal_faction_cost} all require restriction_id, would be good to have card_pool_id as well.
        # TODO(plural): build in explicit support for smart defaults, like restriction_id should imply is_banned = false.  card_pool_id should imply the latest restriction list.
        @parse_tree[:fragments].each {|f|
            if f.include?(:search_term)
                keyword = f[:search_term][:keyword].to_s
                match_type = f[:search_term][:match_type].to_s
                value = f[:search_term][:value][:string].to_s.downcase
                if @@array_keywords.include?(keyword)
                  if @@array_operators.include?(match_type)
                    operator = @@array_operators[match_type]
                  else
                    @parse_error = 'Invalid array operator "%s"' % match_type
                    return
                  end
                  if value.match?(/\A(\w+)-(\d+)\Z/i)
                    value.gsub!('-', '=')
                  end
                  constraints << '%s (? = ANY(%s))' % [operator, @@term_to_field_map[keyword]]
                  where << value
                elsif @@boolean_keywords.include?(keyword)
                    if !['true', 'false', 't', 'f', '1', '0'].include?(value)
                        @parse_error = 'Invalid value "%s" for boolean field "%s"' % [value, keyword]
                        return
                    end
                    operator = ''
                    if @@boolean_operators.include?(match_type)
                        operator = @@boolean_operators[match_type]
                    else
                        @parse_error = 'Invalid boolean operator "%s"' % match_type
                        return
                    end
                    constraints << '%s %s ?' % [@@term_to_field_map[keyword], operator]
                    where << value
                elsif @@numeric_keywords.include?(keyword)
                    if !value.match?(/\A(\d+|x)\Z/i)
                        @parse_error = 'Invalid value "%s" for integer field "%s"' % [value, keyword]
                        return
                    end
                    operator = ''
                    if @@numeric_operators.include?(match_type)
                        operator = @@numeric_operators[match_type]
                    else
                        @parse_error = 'Invalid numeric operator "%s"' % match_type
                        return
                    end
                    constraints << '%s %s ?' % [@@term_to_field_map[keyword], operator]
                    where << (value.downcase == 'x' ? -1 : value) 
                else
                    # String fields only support : and !, resolving to to {,NOT} LIKE %value%.
                    # TODO(plural): consider ~ for regex matches.
                    operator = ''
                    if @@string_operators.include?(match_type)
                        operator = @@string_operators[match_type]
                    else
                        @parse_error = 'Invalid string operator "%s"' % match_type
                        return
                    end
                    constraints << 'lower(%s) %s ?' % [@@term_to_field_map[keyword], operator]
                    where << '%%%s%%' % value
                end
                if @@term_to_left_join_map.include?(keyword)
                    @left_joins << @@term_to_left_join_map[keyword]
                end
             end

            # bare/quoted words in the query are automatically mapped to stripped_title
            if f.include?(:string)
                    value = f[:string].to_s.downcase
                    operator = value.start_with?('!') ? 'NOT LIKE' : 'LIKE'
                    value    = value.start_with?('!') ? value[1..] : value
                    constraints << 'lower(cards.stripped_title) %s ?' % operator
                    where << '%%%s%%' % value
            end
        }
        @where = constraints.join(' AND ')
        @where_values = where
    end
    def parse_error
        return @parse_error
    end
    def where
        return @where
    end
    def where_values
        return @where_values
    end
    def left_joins
        return @left_joins.to_a
    end
end

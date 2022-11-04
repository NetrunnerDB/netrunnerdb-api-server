class PrintingSearchQueryBuilder
    @@parser = PrintingSearchParser.new
    @@array_keywords = [
        'card_pool',
        'card_subtype',
        'card_subtype_id',
        'eternal_points',
        'format',
        'has_global_penalty',
        'illustrator_id',
        'is_banned',
        'is_restricted',
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
    @@date_keywords = [
        'r',
        'release_date'
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
        'quantity',
        'recurring_credits_provided',
        'strength',
        'trash_cost',
        'v',
        'y',
    ]
    @@string_keywords = [
        '_',
        'attribution',
        'card_type',
        'd',
        'f',
        'faction',
        'flavor',
        'i',
        'illustrator',
        'r',
        'release_date',
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
    @@date_operators = {
        ':' => '=',
        '!' => '!=',
        '<' => '<',
        '<=' => '<=',
        '>' => '>',
        '>=' => '>='
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
    @@term_to_field_map = {
        '_' => 'unified_printings.stripped_title',
        'a' => 'unified_printings.flavor',
        'additional_cost' => 'unified_printings.additional_cost',
        'advanceable' => 'unified_printings.advanceable',
        'advancement_cost' => 'unified_printings.advancement_requirement',
        'agenda_points' => 'unified_printings.agenda_points',
        'attribution' => 'unified_printings.attribution',
        'base_link' => 'unified_printings.base_link',
        'c' => 'unified_printings.card_cycle_id',
        'card_cycle' => 'unified_printings.card_cycle_id',
        'card_pool' => 'unified_printings.card_pool_ids',
        'card_set' => 'unified_printings.card_set_id',
        'card_subtype' => 'unified_printings.lower_card_subtype_names',
        'card_subtype_id' => 'unified_printings.card_subtype_ids',
        'card_type' => 'unified_printings.card_type_id',
        'cost' => 'unified_printings.cost',
        'd' => 'unified_printings.side_id',
        'e' => 'unified_printings.card_set_id',
        'eternal_points' => 'unified_printings.restrictions_points',
        'f' => 'unified_printings.faction_id',
        'faction' => 'unified_printings.faction_id',
        'flavor' => 'unified_printings.flavor',
        'format' => 'unified_printings.format_ids',
        'g' => 'unified_printings.advancement_requirement',
        'gains_subroutines' => 'unified_printings.gains_subroutines',
        'has_global_penalty' => 'unified_printings.restrictions_global_penalty',
        'h' => 'unified_printings.trash_cost',
        'illustrator_id' => 'unified_printings.illustrator_ids',
        'i' => 'unified_printings.display_illustrators',
        'illustrator' => 'unified_printings.display_illustrators',
        'in_restriction' => 'unified_printings.in_restriction',
        'influence_cost' => 'unified_printings.influence_cost',
        'interrupt' => 'unified_printings.interrupt',
        'is_banned' => 'unified_printings.restrictions_banned',
        'is_restricted' => 'unified_printings.restrictions_restricted',
        'is_unique' => 'unified_printings.is_unique',
        'l' => 'unified_printings.base_link',
        'link_provided' => 'unified_printings.link_provided',
        'm' => 'unified_printings.memory_cost',
        'memory_usage' => 'unified_printings.memory_cost',
        'mu_provided' => 'unified_printings.mu_provided',
        'n' => 'unified_printings.influence_cost',
        'num_printed_subroutines' => 'unified_printings.num_printed_subroutines',
        'num_printings' => 'unified_printings.num_printings',
        'o' => 'unified_printings.cost',
        'on_encounter_effect' => 'unified_printings.on_encounter_effect',
        'p' => 'unified_printings.strength',
        'performs_trace' => 'unified_printings.performs_trace',
        'quantity' => 'unified_printings.quantity',
        'r' => 'unified_printings.date_release',
        'recurring_credits_provided' => 'unified_printings.recurring_credits_provided',
        'release_date' => 'unified_printings.date_release',
        'restriction_id' => 'unified_printings.restriction_ids',
        's' => 'unified_printings.lower_card_subtype_names',
        'side' => 'unified_printings.card_side_id',
        'strength' => 'unified_printings.strength',
        't' => 'unified_printings.card_type_id',
        'text' => 'unified_printings.stripped_text',
        'title' => 'unified_printings.stripped_title',
        'trash_ability' => 'unified_printings.trash_ability',
        'trash_cost' => 'unified_printings.trash_cost',
        'u' => 'unified_printings.is_unique',
        'universal_faction_cost' => 'unified_printings.restrictions_universal_faction_cost',
        'v' => 'unified_printings.agenda_points',
        'x' => 'unified_printings.stripped_text',
        'y' => 'unified_printings.quantity',
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
                elsif @@date_keywords.include?(keyword)
                    if !value.match?(/\A(\d{4}-\d{2}-\d{2}|\d{8})\Z/)
                        @parse_error = 'Invalid value "%s" for date field "%s" - only YYYY-MM-DD or YYYYMMDD are supported.' % [value, keyword]
                        return
                    end
                    operator = ''
                    if @@date_operators.include?(match_type)
                        operator = @@date_operators[match_type]
                    else
                        @parse_error = 'Invalid numeric operator "%s"' % match_type
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
                    constraints << 'lower(unified_printings.stripped_title) %s ?' % operator
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

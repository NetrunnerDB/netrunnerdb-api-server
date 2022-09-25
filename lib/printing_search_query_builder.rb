class PrintingSearchQueryBuilder
    @@parser = PrintingSearchParser.new
    @@boolean_keywords = [
        'b',
        'banlist',
        'has_global_penalty',
        'in_restriction',
        'is_banned',
        'is_restricted',
        'is_unique',
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
        'eternal_points',
        'g',
        'h',
        'influence_cost',
        'l',
        'm',
        'memory_usage',
        'n',
        'o',
        'p',
        'quantity',
        'strength',
        'trash_cost',
        'universal_faction_cost',
        'v',
        'y',
    ]
    @@string_keywords = [
        '_',
        'card_type',
        'd',
        'f',
        'faction',
        'flavor',
        'i',
        'illustrator',
        'r',
        'release_date',
        'restriction_id',
        'side',
        't',
        'text',
        'title',
        'x',
    ]
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
        '_' => 'cards.stripped_title',
        'a' => 'printings.flavor',
        'advancement_cost' => 'cards.advancement_requirement',
        'agenda_points' => 'cards.agenda_points',
        'base_link' => 'cards.base_link',
        'c' => 'card_sets.card_cycle_id',
        'card_cycle' => 'card_sets.card_cycle_id',
        'card_pool' => 'card_pools_cards.card_pool_id',
        'card_set' => 'printings.card_set_id',
        'card_subtype' => 'card_subtypes.name',
        'card_type' => 'cards.card_type_id',
        'cost' => 'cards.cost',
        'd' => 'cards.side_id',
        'e' => 'printings.card_set_id',
        'eternal_points' => 'unified_restrictions.eternal_points',
        'f' => 'cards.faction_id',
        'faction' => 'cards.faction_id',
        'flavor' => 'printings.flavor',
        'format' => 'unified_restrictions.format_id',
        'g' => 'cards.advancement_requirement',
        'has_global_penalty' => 'unified_restrictions.has_global_penalty',
        'h' => 'cards.trash_cost',
        'i' => 'illustrators.name',
        'illustrator' => 'illustrators.name',
        'in_restriction' => 'unified_restrictions.in_restriction',
        'influence_cost' => 'cards.influence_cost',
        'is_banned' => 'unified_restrictions.is_banned',
        'is_restricted' => 'unified_restrictions.is_restricted',
        'is_unique' => 'cards.is_unique',
        'l' => 'cards.base_link',
        'm' => 'cards.memory_cost',
        'memory_usage' => 'cards.memory_cost',
        'n' => 'cards.influence_cost',
        'o' => 'cards.cost',
        'p' => 'cards.strength',
        'quantity' => 'printings.quantity',
        'r' => 'printings.date_release',
        'release_date' => 'printings.date_release',
        'restriction_id' => 'unified_restrictions.restriction_id',
        's' => 'card_subtypes.name',
        'side' => 'cards.card_side_id',
        'strength' => 'cards.strength',
        't' => 'cards.card_type_id',
        'text' => 'cards.stripped_text',
        'title' => 'cards.stripped_title',
        'trash_cost' => 'cards.trash_cost',
        'u' => 'cards.is_unique',
        'universal_faction_cost' => 'unified_restrictions.universal_faction_cost',
        'v' => 'cards.agenda_points',
        'x' => 'cards.stripped_text',
        'y' => 'printings.quantity',
    }

    # TODO(plural): Unify more of this with card_search_query_builder.
    @@term_to_left_join_map = {
        '_' => :card,
        'advancement_cost' => :card,
        'agenda_points' => :card,
        'base_link' => :card,
        'c' => :card_set,
        'card_cycle' => :card_set,
        'card_pool' => :card_pool_cards,
        'card_subtype' => :card_subtypes,
        'card_type' => :card,
        'cost' => :card,
        'd' => :card,
        'eternal_points' => :unified_restrictions,
        'f' => :card,
        'faction' => :card,
        'format' => :unified_restrictions,
        'g' => :card,
        'has_global_penalty' => :unified_restrictions,
        'h' => :card,
        'i' => :illustrators,
        'illustrator' => :illustrators,
        'in_restriction' => :unified_restrictions,
        'influence_cost' => :card,
        'is_banned' => :unified_restrictions,
        'is_restricted' => :unified_restrictions,
        'is_unique' => :card,
        'l' => :card,
        'm' => :card,
        'memory_usage' => :card,
        'n' => :card,
        'o' => :card,
        'p' => :card,
        'restriction_id' => :unified_restrictions,
        's' => :card_subtypes,
        'side' => :card,
        'strength' => :card,
        't' => :card,
        'text' => :card,
        'title' => :card,
        'trash_cost' => :card,
        'u' => :card,
        'universal_faction_cost' => :unified_restrictions,
        'v' => :card,
        'x' => :card,
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
                if @@boolean_keywords.include?(keyword)
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
                    if !value.match?(/\A\d+\Z/)
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
                    where << value
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

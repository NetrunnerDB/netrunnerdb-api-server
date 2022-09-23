class CardSearchQueryBuilder
    @@parser = CardSearchParser.new
    @@boolean_keywords = [
        'b',
        'banlist',
        'in_restriction',
        'is_banned',
        'is_restricted',
        'is_unique',
        'u',
    ]
    @@numeric_keywords = [
        'advancement_cost',
        'agenda_points',
        'base_link',
        'cost',
        'eternal_points',
        'g',
        'global_penalty',
        'h',
        'influence_cost',
        'l',
        'm',
        'memory_usage',
        'n',
        'o',
        'p',
        'strength',
        'trash_cost',
        'universal_faction_cost',
        'v',
    ]
    @@string_keywords = [
        '_',
        'card_type',
        'd',
        'f',
        'faction',
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
        # format should implicitly use the currently active card pool and restriction lists unless another is specified.
        '_' => 'cards.stripped_title',
        'advancement_cost' => 'cards.advancement_requirement',
        'agenda_points' => 'cards.agenda_points',
        'base_link' => 'cards.base_link',
        'card_pool' => 'card_pools_cards.card_pool_id',
        'card_subtype' => 'card_subtypes.name',
        'card_type' => 'cards.card_type_id',
        'cost' => 'cards.cost',
        'd' => 'cards.side_id',
        'eternal_points' => 'unified_restrictions.eternal_points',
        'f' => 'cards.faction_id',
        'faction' => 'cards.faction_id',
        'format' => 'unified_restrictions.format_id',
        'g' => 'cards.advancement_requirement',
        'global_penalty' => 'unified_restrictions.global_penalty',
        'h' => 'cards.trash_cost',
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
    }

    @@term_to_left_join_map = {
        'card_pool' => :card_pool_cards,
        'card_subtype' => :card_subtypes,
        'eternal_points' => :unified_restrictions,
        'global_penalty' => :unified_restrictions,
        'in_restriction' => :unified_restrictions,
        'is_banned' => :unified_restrictions,
        'is_restricted' => :unified_restrictions,
        'restriction_id' => :unified_restrictions,
        's' => :card_subtypes,
        'universal_faction_cost' => :unified_restrictions,
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
        #   {is_banned,is_restricted,eternal_points,global_penalty,universal_faction_cost} all require restriction_id, would be good to have card_pool_id as well.
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

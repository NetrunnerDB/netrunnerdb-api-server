# TODO(plural): Add attribution to cards.
class CardSearchQueryBuilder
    @@parser = CardSearchParser.new
    @@array_keywords = [
        'card_cycle',
        'card_pool',
        'card_set',
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
        'attribution',
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
    # TODO(plural): figure out how to do name matches that are LIKEs over elements of an array.
    @@term_to_field_map = {
        # format should implicitly use the currently active card pool and restriction lists unless another is specified.
        '_' => 'unified_cards.stripped_title',
        'additional_cost' => 'unified_cards.additional_cost',
        'advanceable' => 'unified_cards.advanceable',
        'advancement_cost' => 'unified_cards.advancement_requirement',
        'agenda_points' => 'unified_cards.agenda_points',
        'attribution' => 'unified_cards.attribution',
        'base_link' => 'unified_cards.base_link',
        'card_cycle' => 'unified_cards.card_cycle_ids',
        'card_pool' => 'unified_cards.card_pool_ids',
        'card_set' => 'unified_cards.card_set_ids',
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

    def parse_node(node)
        key = node.keys[0]
        case key
        when :ors
            children = node[key].kind_of?(Array) ? node[key] : [node[key]]
            children.map! { |child| parse_node(child) }
            return '(' + children.join(' OR ') + ')'
        when :ands
            children = node[key].kind_of?(Array) ? node[key] : [node[key]]
            children.map! { |child| parse_node(child) }
            return '(' + children.join(' AND ') + ')'
        when :negate
            child = node[key]
            return '(NOT ' + parse_node(child) + ')'
        when :pair
            pair = node[key]
            keyword = pair[:keyword].to_s
            operator = pair[:operator].to_s
            values = pair[:values].kind_of?(Array) ? pair[:values] : [pair[:values]]
            values.map! { |v| v[:string].to_s }
            return parse_pair(keyword, operator, values)
        when :title
            return parse_pair('_', ':', [node[key][:string]])
        else
            return '?'
        end
    end

    def parse_pair(keyword, operator, values)
        out = []
        if @@array_keywords.include?(keyword)
            if @@array_operators.include?(operator)
                operator = @@array_operators[operator]
            else
                @parse_error = 'Invalid array operator "%s"' % operator
                return
            end
            values.map! { |value|
                if value.match?(/\A(\w+)-(\d+)\Z/i)
                    value.gsub!('-', '=')
                end
            }
            where_values.concat(values)
            out = values.map { |_| '%s (? = ANY(%s))' % [operator, @@term_to_field_map[keyword]] }
        elsif @@boolean_keywords.include?(keyword)
            values.each { |value|
                if !['true', 'false', 't', 'f', '1', '0'].include?(value)
                    @parse_error = 'Invalid value "%s" for boolean field "%s"' % [value, keyword]
                    return
                end
            }
            dbOp = ''
            if @@boolean_operators.include?(operator)
                dbOp = @@boolean_operators[operator]
            else
                @parse_error = 'Invalid boolean operator "%s"' % operator
                return
            end
            where_values.concat(values)
            out = values.map { |_| '%s %s ?' % [@@term_to_field_map[keyword], dbOp] }
        elsif @@numeric_keywords.include?(keyword)
            values.each { |value|
                if !value.match?(/\A(\d+|x)\Z/i)
                    @parse_error = 'Invalid value "%s" for integer field "%s"' % [value, keyword]
                    return
                end
            }
            dbOp = ''
            if @@numeric_operators.include?(operator)
                dbOp = @@numeric_operators[operator]
            else
                @parse_error = 'Invalid numeric operator "%s"' % operator
                return
            end
            where_values.concat(values.map { |value| value.downcase == 'x' ? -1 : value })
            out = values.map { |_| '%s %s ?' % [@@term_to_field_map[keyword], dbOp] }
        else
            # String fields only support : and !, resolving to to {,NOT} LIKE %value%.
            # TODO(plural): consider ~ for regex matches.
            dbOp = ''
            if @@string_operators.include?(operator)
                dbOp = @@string_operators[operator]
            else
                @parse_error = 'Invalid string operator "%s"' % operator
                return
            end
            where_values.concat(values.map { |value| '%%%s%%' % value })
            out = values.map { |_| 'lower(%s) %s ?' % [@@term_to_field_map[keyword], dbOp] }
        end

        # Not sure what this is for
        if @@term_to_left_join_map.include?(keyword)
            @left_joins << @@term_to_left_join_map[keyword]
        end

        # Format output
        return out.join(operator == '!' ? ' and ' : ' or ')
    end

    def initialize(query)
        @query = query
        @parse_error = nil
        @parse_tree = nil
        @left_joins = Set.new
        @where = ''
        @where_values = []

        # Parse the input into an AST
        begin
            @parse_tree = @@parser.parse(@query)
        rescue Parslet::ParseFailed => e
            @parse_error = e
        end

        # Parse the AST into a databse query
        @where = parse_node(@parse_tree)

        # Raise errors
        if @parse_error != nil
            return
        end

        # TODO(plural): build in explicit support for requirements
        #   {is_banned,is_restricted,eternal_points,has_global_penalty,universal_faction_cost} all require restriction_id, would be good to have card_pool_id as well.
        # TODO(plural): build in explicit support for smart defaults, like restriction_id should imply is_banned = false.  card_pool_id should imply the latest restriction list.
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

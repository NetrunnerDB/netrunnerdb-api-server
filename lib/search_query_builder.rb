require 'search_parser'
class SearchQueryBuilder
    @@parser = SearchParser.new
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
    @@numeric_keywords = [
        'advancement_cost',
        'agenda_points',
        'base_link',
        'cost',
        'g',
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
        'v',
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
    @@boolean_keywords = [ 'is_unique', 'u' ]
    @@term_to_field_map = {
        # 'card_pool' => ''',
        # 'format' => ''',
        # 'r' => 'release_date',
        # 'restriction' => ''',
        # banlist 'b' => '',
        # needs join table 'card_subtype' => ''',
        # printing 'a' => 'flavor',
        # printing 'c' => 'card_cycle_id',
        # printing 'card_cycle' => 'card_cycle_id'',
        # printing 'card_set' => 'card_set_id'',
        # printing 'e' => 'card_set_id',
        # printing 'i' => 'illustrator',
        # printing 'quantity_in_card_set' => ''',
        # printing 'release_date' => ''',
        # printing flavor 'flavor_text' => ''',
        # printing illustrator 'illustrator' => ''',
        # printing quantity 'y' => ''',
        # rotation 'z' => ''',
        # subtypes 's' => ''',
        '_' => 'stripped_title',
        'advancement_cost' => 'advancement_requirement',
        'agenda_points' => 'agenda_points',
        'base_link' => 'base_link',
        'card_type' => 'card_type_id',
        'cost' => 'cost',
        'd' => 'side_id',
        'f' => 'faction_id',
        'faction' => 'faction_id',
        'g' => 'advancement_requirement',
        'h' => 'trash_cost',
        'influence_cost' => 'influence_cost',
        'is_unique' => 'is_unique',
        'l' => 'base_link',
        'm' => 'memory_cost',
        'memory_usage' => 'memory_cost',
        'n' => 'influence_cost',
        'o' => 'cost',
        'p' => 'strength',
        'side' => 'card_side_id',
        'strength' => 'strength',
        't' => 'card_type_id',
        'text' => 'stripped_text',
        'title' => 'stripped_title',
        'trash_cost' => 'trash_cost',
        'u' => 'is_unique',
        'v' => 'agenda_points',
        'x' => 'stripped_text',
    }

    def initialize(query)
        @query = query
        @parse_error = nil
        @parse_tree = nil
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
        @parse_tree[:fragments].each {|f|
            if f.include?(:search_term)
                keyword = f[:search_term][:keyword].to_s
                match_type = f[:search_term][:match_type].to_s
                value = f[:search_term][:value][:string].to_s
                if @@boolean_keywords.include?(keyword)
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
                    # String fields only support : and !
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
            end

            # bare/quoted words in the query are automatically mapped to stripped_title
            if f.include?(:string)
                    value = f[:string].to_s
                    operator = value.start_with?('!') ? 'NOT LIKE' : 'LIKE'
                    value    = value.start_with?('!') ? value[1..] : value
                    constraints << 'lower(stripped_title) %s ?' % operator
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
end
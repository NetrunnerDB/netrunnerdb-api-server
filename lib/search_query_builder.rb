require 'search_parser'
class SearchQueryBuilder
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
        # TODO(plural): Could be a singleton
        @parser = SearchParser.new
        @parse_tree = nil
        @where = ''
        @where_values = []
        begin
            @parse_tree = @parser.parse(@query)
        rescue Parslet::ParseFailed => e
            @parse_error = e
        end
        if @parse_error != nil
            return
        end
        constraints = []
        @parse_tree[:fragments].each {|f|
            if f.include?(:search_term)
                if @@boolean_keywords.include?(f[:search_term][:keyword])
                    operator = ''
                    if @@boolean_operators.include?(f[:search_term][:match_type].to_s)
                        operator = @@boolean_operators[f[:search_term][:match_type].to_s]
                    else
                        # TODO(plural): throw an error earlier for invalid operator
                    end
                    constraints << '%s %s ?' % [@@term_to_field_map[f[:search_term][:keyword].to_s], operator]
                    @where_values << f[:search_term][:value][:string].to_s
                elsif @@numeric_keywords.include?(f[:search_term][:keyword].to_s)
                    operator = ''
                    if @@numeric_operators.include?(f[:search_term][:match_type].to_s)
                        operator = @@numeric_operators[f[:search_term][:match_type].to_s]
                    else
                        # TODO(plural): throw an error earlier for invalid operator
                    end
                    constraints << '%s %s ?' % [@@term_to_field_map[f[:search_term][:keyword].to_s], operator]
                    @where_values << f[:search_term][:value][:string].to_s
                else
                    # String fields only support : and !
                    operator = ''
                    if @@string_operators.include?(f[:search_term][:match_type].to_s)
                        operator = @@string_operators[f[:search_term][:match_type].to_s]
                    else
                        # TODO(plural): throw an error earlier for invalid operator
                    end
                    constraints << 'lower(%s) %s ?' % [@@term_to_field_map[f[:search_term][:keyword].to_s], operator]
                    @where_values << '%%%s%%' % f[:search_term][:value][:string].to_s
                end
            end
            # bare/quoted words in the query are automatically mapped to stripped_title
            if f.include?(:string)
                    constraints << 'lower(stripped_title) LIKE ?'
                    @where_values << '%%%s%%' % f[:string].to_s
            end
        }
        @where = constraints.join(' AND ')
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
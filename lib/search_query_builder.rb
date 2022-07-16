require 'search_parser'

class SearchQueryBuilder
    @@string_keywords = [
        '_',
        'd',
        'f',
        't',
        'x',
        'title',
        'text',
        'card_type',
        'faction',
        'side',
    ]
    @@numeric_keywords = [
        'g',
        'h',
        'l',
        'm',
        'n',
        'o',
        'p',
        'v',
        'cost',
        'advancement_cost',
        'base_link',
        'memory_usage',
        'influence_cost',
        'strength',
        'agenda_points',
        'trash_cost',
    ]
    @@boolean_keywords = [ 'u', 'is_unique' ]
    @@term_to_field_map = {
        '_' => 'stripped_title',
        # printing 'a' => 'flavor',
        # banlist 'b' => '',
        # printing 'c' => 'card_cycle_id',
        'd' => 'side_id',
        # printing 'e' => 'card_set_id',
        'f' => 'faction_id',
        'g' => 'advancement_requirement',
        'h' => 'trash_cost',
        # printing 'i' => 'illustrator',
        'l' => 'base_link',
        'm' => 'memory_cost',
        'n' => 'influence_cost',
        'o' => 'cost',
        'p' => 'strength',
        # 'r' => 'release_date',
        # subtypes 's' => ''',
        't' => 'card_type_id',
        'u' => 'is_unique',
        'v' => 'agenda_points',
        'x' => 'stripped_text',
        # printing quantity 'y' => ''',
        # rotation 'z' => ''',
        'title' => 'stripped_title',
        'text' => 'stripped_text',
        # printing flavor 'flavor_text' => ''',
        # printing 'card_set' => 'card_set_id'',
        # printing 'card_cycle' => 'card_cycle_id'',
        'card_type' => 'card_type_id',
        'faction' => 'faction_id',
        # needs join table 'card_subtype' => ''',
        'side' => 'card_side_id',
        # printing illustrator 'illustrator' => ''',
        'cost' => 'cost',
        'advancement_cost' => 'advancement_requirement',
        'base_link' => 'base_link',
        'memory_usage' => 'memory_cost',
        'influence_cost' => 'influence_cost',
        'strength' => 'strength',
        'agenda_points' => 'agenda_points',
        'trash_cost' => 'trash_cost',
        # printing 'release_date' => ''',
        'is_unique' => 'is_unique',
        # printing 'quantity_in_card_set' => ''',
        # 'restriction' => ''',
        # 'card_pool' => ''',
        # 'format' => ''',
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
                    constraints << '%s = ?' % [@@term_to_field_map[f[:search_term][:keyword].to_s]] 
                    @where_values << f[:search_term][:value][:string].to_s
                elsif @@numeric_keywords.include?(f[:search_term][:keyword])
                    constraints << '%s = ?' % [@@term_to_field_map[f[:search_term][:keyword].to_s]] 
                    @where_values << f[:search_term][:value][:string].to_s
                else
                    constraints << 'lower(%s) LIKE ?' % [@@term_to_field_map[f[:search_term][:keyword].to_s]] 
                    @where_values << '%%%s%%' % f[:search_term][:value][:string].to_s
                end
            end
            # bare/quoted words in the query are automatically mapped to title 
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
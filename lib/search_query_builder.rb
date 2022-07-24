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
    # restriction:
    # Card.left_joins(:restrictions).merge(Restriction.where.not(id: "standard_mwl_3_4").or(Restriction.where(id: nil))).size
    # SELECT cards.* FROM "cards" LEFT OUTER JOIN "restrictions_cards_banned" ON "restrictions_cards_banned"."card_id" = "cards"."id" LEFT OUTER JOIN "restrictions" ON "restrictions"."id" = "restrictions_cards_banned"."restriction_id" WHERE ("restrictions"."id" != $1 OR "restrictions"."id" IS NULL)  [["id", "standard_mwl_3_4"]]  

        # 'card_pool' => ''',

        # format should implicitly use the latest card pool and restriction lists unless another is specified.
        # 'format' => ''',
        # 'restriction' => ''',

        # banlist 'b' => '',
        # printing? or minimum release date from printing for the card?  Add release date to the card? 'r' => 'release_date', 
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

        '_' => 'cards.stripped_title',
        'advancement_cost' => 'cards.advancement_requirement',
        'agenda_points' => 'cards.agenda_points',
        'b' => 'restrictions_cards_banned.restriction_id',
        'banlist' => 'restrictions_cards_banned.restriction_id',
        'base_link' => 'cards.base_link',
        'card_pool' => 'card_pools_cards.card_pool_id',
        'card_subtype' => 'card_subtypes.name',
        'card_type' => 'cards.card_type_id',
        'cost' => 'cards.cost',
        'd' => 'cards.side_id',
        'f' => 'cards.faction_id',
        'faction' => 'cards.faction_id',
        'g' => 'cards.advancement_requirement',
        'h' => 'cards.trash_cost',
        'influence_cost' => 'cards.influence_cost',
        'is_unique' => 'cards.is_unique',
        'l' => 'cards.base_link',
        'm' => 'cards.memory_cost',
        'memory_usage' => 'cards.memory_cost',
        'n' => 'cards.influence_cost',
        'o' => 'cards.cost',
        'p' => 'cards.strength',
        's' => 'card_subtypes.name',
        'side' => 'cards.card_side_id',
        'strength' => 'cards.strength',
        't' => 'cards.card_type_id',
        'text' => 'cards.stripped_text',
        'title' => 'cards.stripped_title',
        'trash_cost' => 'cards.trash_cost',
        'u' => 'cards.is_unique',
        'v' => 'cards.agenda_points',
        'x' => 'cards.stripped_text',
    }

    def initialize(query)
        @query = query
        @parse_error = nil
        @parse_tree = nil
        @left_joins = []
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
                value = f[:search_term][:value][:string].to_s.downcase
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
                    if ['s', 'card_subtype'].include?(keyword)
                        @left_joins << :card_subtypes
                    elsif ['b', 'banlist'].include?(keyword)
                        @left_joins << :restrictions_cards_banned
                    elsif keyword == 'card_pool'
                        @left_joins << :card_pool_cards
                    end
                    constraints << 'lower(%s) %s ?' % [@@term_to_field_map[keyword], operator]
                    where << '%%%s%%' % value
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
        return @left_joins
    end
end

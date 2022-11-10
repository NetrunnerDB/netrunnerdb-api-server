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
    @@regex_operators = {
        ':' => '~*',
        '!' => '!~*',
    }

    class Node < Struct
      def construct_clause(parameters)
        raise 'construct_clause not implemented in ' + self.class.name
      end
    end

    NodeLiteral = Node.new(:value, :is_regex) do
      def construct_clause(parameters)
        value
      end
    end

    NodeKeyword = Node.new(:name) do
      def construct_clause(parameters)
        name
      end
    end

    NodeNegate = Node.new(:child) do
      def construct_clause(parameters)
        'not ' + child.construct_clause(parameters)
      end
    end

    NodeOperator = Node.new(:operator) do
      def is_negative
        operator == '!'
      end
      def construct_clause(parameters)
        operator
      end
    end

    NodePair = Node.new(:keyword_node, :operator_node, :value_nodes) do
      def construct_clause(parameters)
        regex_value = value_nodes.find { |v| v.is_regex }
        regex_present = regex_value != nil

        keyword = keyword_node.construct_clause(parameters)
        operator = operator_node.construct_clause(parameters)
        values = value_nodes.map { |v| v.construct_clause(parameters) }

        out = []

        # Array fields
        if @@array_keywords.include?(keyword)
          if regex_present
            raise 'Array field does not accept regular expressions but was passed %s' % regex_value
          elsif @@array_operators.include?(operator)
            operator = @@array_operators[operator]
          else
            raise 'Invalid array operator "%s"' % operator
          end
          values.map! { |value|
            if value.match?(/\A(\w+)-(\d+)\Z/i)
              value.gsub!('-', '=')
            end
          }
          parameters.concat(values)
          out = values.map { |_| '%s (? = ANY(%s))' % [operator, @@term_to_field_map[keyword]] }

        # Boolean fields
        elsif @@boolean_keywords.include?(keyword)
          if regex_present
            raise 'Boolean field does not accept regular expressions but was passed %s' % regex_value
          end
          values.each { |value|
            if !['true', 'false', 't', 'f', '1', '0'].include?(value)
              raise 'Invalid value "%s" for boolean field "%s"' % [value, keyword]
            end
          }
          if @@boolean_operators.include?(operator)
            operator = @@boolean_operators[operator]
          else
            raise 'Invalid boolean operator "%s"' % operator
          end
          parameters.concat(values)
          out = values.map { |_| '%s %s ?' % [@@term_to_field_map[keyword], operator] }

        # Integer fields
        elsif @@numeric_keywords.include?(keyword)
          if regex_present
            raise 'Integer field does not accept regular expressions but was passed %s' % regex_value
          end
          values.each { |value|
            if !value.match?(/\A(\d+|x)\Z/i)
              raise 'Invalid value "%s" for integer field "%s"' % [value, keyword]
            end
          }
          if @@numeric_operators.include?(operator)
            operator = @@numeric_operators[operator]
          else
            raise 'Invalid numeric operator "%s"' % operator
          end
          parameters.concat(values.map { |value| value.downcase == 'x' ? -1 : value })
          out = values.map { |_| '%s %s ?' % [@@term_to_field_map[keyword], operator] }

        # String fields
        else
          value_nodes.each_with_index { |v,i|
            if v.is_regex
              if @@regex_operators.include?(operator)
                op = @@regex_operators[operator]
                parameters << "%s" % values[i]
              else
                raise 'Invalid regex operator "%s"' % op
              end
            else
              if @@string_operators.include?(operator)
                op = @@string_operators[operator]
                parameters << '%%%s%%' % values[i].downcase
              else
                raise 'Invalid string operator "%s"' % op
              end
            end
            out << 'lower(%s) %s ?' % [@@term_to_field_map[keyword], op]
          }
        end

        # Return
        bracs = values.length > 1 ? ['(', ')'] : ['', '']
        connector = operator_node.is_negative ? ' and ' : ' or '
        bracs[0] + out.join(connector) + bracs[1]
      end
    end

    NodeAnd = Node.new(:children) do
      def construct_clause(parameters)
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause(parameters) }.join(' and ') + bracs[1]
      end
    end

    NodeOr = Node.new(:children) do
      def construct_clause(parameters)
        bracs = children.length > 1 ? ['(', ')'] : ['', '']
        bracs[0] + children.map { |c| c.construct_clause(parameters) }.join(' or ') + bracs[1]
      end
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
            return
        end

        # Convert raw parse tree into an AST
        transform = Parslet::Transform.new do
          # Match literals
          rule(:string => simple(:s)) { NodeLiteral.new(s.to_s) }
          rule(:regex => simple(:r)) { NodeLiteral.new(r.to_s, true) }

          # Match title queries
          rule(:singular => simple(:s)) { NodePair.new(NodeKeyword.new('_'), NodeOperator.new(':'), [s]) }

          # Match pairs
          rule(:keyword => simple(:k), :operator => simple(:o), :values => simple(:v)) {
            NodePair.new(
              NodeKeyword.new(k.to_s), NodeOperator.new(o.to_s), [v]
            )
          }
          rule(:keyword => simple(:k), :operator => simple(:o), :values => sequence(:vs)) {
            NodePair.new(
              NodeKeyword.new(k.to_s), NodeOperator.new(o.to_s), vs
            )
          }

          # Match negation
          rule(:negate => simple(:u)) { NodeNegate.new(u) }

          # Match conjunctions
          rule(:ands => simple(:a)) { NodeAnd.new([a]) }
          rule(:ands => sequence(:as)) { NodeAnd.new(as) }
          rule(:ors => simple(:o)) { NodeOr.new([o]) }
          rule(:ors => sequence(:os)) { NodeOr.new(os) }
        end

        # Generate SQL query and parameters from AST
        @where = transform.apply(@parse_tree).construct_clause(@where_values)

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

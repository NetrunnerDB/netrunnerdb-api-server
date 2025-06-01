# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrintingSearchQueryBuilder do
  describe '#initialize' do
    it 'parses a simple successful query' do
      builder = described_class.new('x:trash')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('lower(unified_printings.stripped_text) LIKE ?')
      expect(builder.where_values).to eq(['%trash%'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses a query with multiple terms' do
      builder = described_class.new('x:trash cost:3')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('lower(unified_printings.stripped_text) LIKE ? AND unified_printings.cost = ?')
      expect(builder.where_values).to eq(['%trash%', '3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses numeric field not equal' do
      builder = described_class.new('trash_cost!3')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('unified_printings.trash_cost != ?')
      expect(builder.where_values).to eq(['3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses numeric field less than' do
      builder = described_class.new('trash_cost<3')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('unified_printings.trash_cost < ?')
      expect(builder.where_values).to eq(['3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses numeric field less than or equal to' do
      builder = described_class.new('trash_cost<=3')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('unified_printings.trash_cost <= ?')
      expect(builder.where_values).to eq(['3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses numeric field greater than' do
      builder = described_class.new('trash_cost>3')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('unified_printings.trash_cost > ?')
      expect(builder.where_values).to eq(['3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses numeric field greater than or equal to' do
      builder = described_class.new('trash_cost>=3')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('unified_printings.trash_cost >= ?')
      expect(builder.where_values).to eq(['3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses string field not like' do
      builder = described_class.new('title!sure')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('lower(unified_printings.stripped_title) NOT LIKE ?')
      expect(builder.where_values).to eq(['%sure%'])
      expect(builder.left_joins).to eq([])
    end

    it 'raises on bad boolean operators' do
      ['<', '<=', '>', '>='].each do |op|
        expect do
          described_class.new("is_unique#{op}true")
        end.to raise_error(RuntimeError, "Invalid boolean operator \"#{op}\"")
      end
    end

    it 'raises on bad string operators' do
      ['<', '<=', '>', '>='].each do |op|
        expect do
          described_class.new("title#{op}sure")
        end.to raise_error(RuntimeError, "Invalid string operator \"#{op}\"")
      end
    end

    it 'parses a bare word' do
      builder = described_class.new('diversion')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('lower(unified_printings.stripped_title) LIKE ?')
      expect(builder.where_values).to eq(['%diversion%'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses a negated bare word' do
      builder = described_class.new('!diversion')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('NOT lower(unified_printings.stripped_title) LIKE ?')
      expect(builder.where_values).to eq(['%diversion%'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses a negated quoted string' do
      builder = described_class.new('!"diversion of funds"')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('NOT lower(unified_printings.stripped_title) LIKE ?')
      expect(builder.where_values).to eq(['%diversion of funds%'])
      expect(builder.left_joins).to eq([])
    end

    it 'strips unicode for query' do
      builder = described_class.new('"Chaos Theory: Wünderkind"')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('lower(unified_printings.stripped_title) LIKE ?')
      expect(builder.where_values).to eq(['%chaos theory: wunderkind%'])
      expect(builder.left_joins).to eq([])
    end

    it 'raises on unknown keyword' do
      expect do
        described_class.new('asdfasdf:bleargh')
      end.to raise_error(RuntimeError, 'Unknown keyword asdfasdf')
    end

    it 'parses is_banned without restriction' do
      builder = described_class.new('is_banned:true')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_banned))')
      expect(builder.where_values).to eq(['true'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses is_restricted without restriction' do
      builder = described_class.new('is_restricted:true')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_restricted))')
      expect(builder.where_values).to eq(['true'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses has_global_penalty without restriction' do
      builder = described_class.new('has_global_penalty:true')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_global_penalty))')
      expect(builder.where_values).to eq(['true'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses is_banned with restriction' do
      builder = described_class.new('is_banned:true restriction_id:ban_list_foo')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_banned)) AND  (? = ANY(unified_printings.restriction_ids))') # rubocop:disable Layout/LineLength
      expect(builder.where_values).to eq(%w[true ban_list_foo])
      expect(builder.left_joins).to eq([])
    end

    it 'parses is_restricted with restriction' do
      builder = described_class.new('is_restricted:true restriction_id:ban_list_foo')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_restricted)) AND  (? = ANY(unified_printings.restriction_ids))') # rubocop:disable Layout/LineLength
      expect(builder.where_values).to eq(%w[true ban_list_foo])
      expect(builder.left_joins).to eq([])
    end

    it 'parses has_global_penalty with restriction' do
      builder = described_class.new('has_global_penalty:true restriction_id:ban_list_foo')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_global_penalty)) AND  (? = ANY(unified_printings.restriction_ids))') # rubocop:disable Layout/LineLength
      expect(builder.where_values).to eq(%w[true ban_list_foo])
      expect(builder.left_joins).to eq([])
    end

    it 'parses eternal_points' do
      builder = described_class.new('eternal_points:eternal_restriction_id-3')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_points))')
      expect(builder.where_values).to eq(['eternal_restriction_id=3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses universal_faction_cost' do
      builder = described_class.new('universal_faction_cost:3')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.restrictions_universal_faction_cost))')
      expect(builder.where_values).to eq(['3'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses card_pool' do
      builder = described_class.new('card_pool:best_pool')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('(? = ANY(unified_printings.card_pool_ids))')
      expect(builder.where_values).to eq(['best_pool'])
      expect(builder.left_joins).to eq([])
    end

    it 'raises on bad boolean value' do
      expect do
        described_class.new('additional_cost:nah')
      end.to raise_error(RuntimeError, 'Invalid value "nah" for boolean field "additional_cost"')
    end

    it 'raises on bad numeric value' do
      expect do
        described_class.new('trash_cost:"too damn high"')
      end.to raise_error(RuntimeError, 'Invalid value "too damn high" for integer field "trash_cost"')
    end

    it 'parses release_date full' do
      builder = described_class.new('release_date:2022-07-22')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('unified_printings.date_release = ?')
      expect(builder.where_values).to eq(['2022-07-22'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses release_date short' do
      builder = described_class.new('r>=20220722')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('unified_printings.date_release >= ?')
      expect(builder.where_values).to eq(['20220722'])
      expect(builder.left_joins).to eq([])
    end

    it 'raises on bad date value' do
      expect do
        described_class.new('release_date:Jul-22-2022')
      end.to raise_error(RuntimeError,
                         'Invalid value "jul-22-2022" for date field "release_date" - only YYYY-MM-DD or YYYYMMDD are supported.') # rubocop:disable Layout/LineLength
    end

    it 'parses illustrator full' do
      builder = described_class.new('illustrator:Zeilinger')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('lower(unified_printings.display_illustrators) LIKE ?')
      expect(builder.where_values).to eq(['%zeilinger%'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses illustrator short' do
      builder = described_class.new('i!Zeilinger')
      expect(builder.parse_error).to be_nil
      expect(builder.where).to eq('lower(unified_printings.display_illustrators) NOT LIKE ?')
      expect(builder.where_values).to eq(['%zeilinger%'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses designed_by for both Card and Printing' do
      input = 'designed_by:best_org'
      [
        { builder: CardSearchQueryBuilder.new(input), table: 'cards' },
        { builder: described_class.new(input), table: 'printings' }
      ].each do |b|
        expect(b[:builder].parse_error).to be_nil
        expect(b[:builder].where.strip).to eq("lower(unified_#{b[:table]}.designed_by) LIKE ?")
        expect(b[:builder].where_values).to eq(['%best_org%'])
        expect(b[:builder].left_joins).to eq([])
      end
    end

    it 'parses released_by' do
      builder = described_class.new('released_by:best_org')
      expect(builder.parse_error).to be_nil
      expect(builder.where.strip).to eq('lower(unified_printings.released_by) LIKE ?')
      expect(builder.where_values).to eq(['%best_org%'])
      expect(builder.left_joins).to eq([])
    end

    it 'parses printings_released_by for both Card and Printing' do
      input = 'printings_released_by:best_org'
      [
        { builder: CardSearchQueryBuilder.new(input), table: 'cards' },
        { builder: described_class.new(input), table: 'printings' }
      ].each do |b|
        expect(b[:builder].parse_error).to be_nil
        expect(b[:builder].where.strip).to eq("(? = ANY(unified_#{b[:table]}.printings_released_by))")
        expect(b[:builder].where_values).to eq(['best_org'])
        expect(b[:builder].left_joins).to eq([])
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'parslet/convenience'

RSpec.describe SearchParser do
  describe '#keyword' do
    it 'parses a keyword' do
      input = %(t)
      parser = described_class.new.keyword
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end

    it 'fails with non-keyword' do
      inputs = [%(...), %(1)]
      parser = described_class.new.keyword
      inputs.each do |i|
        expect do
          parser.parse(i)
        end.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe '#operator' do
    it 'parses an operator' do
      operators = [':', '!', '>', '<', '<=', '>=']
      parser = described_class.new.operator
      operators.each do |o|
        tree = parser.parse_with_debug(o)
        expect(tree).not_to be_nil
      end
    end

    it 'fails with non-operator' do
      inputs = ['a', '?', '&', '(', '-']
      parser = described_class.new.operator
      inputs.each do |o|
        expect do
          parser.parse(o)
        end.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe '#values' do
    it 'parses a simple value' do
      values = %w[a weyland-consortium 1 01-01-1970]
      parser = described_class.new.values
      values.each do |v|
        tree = parser.parse_with_debug(v)
        expect(tree).not_to be_nil
      end
    end

    it 'parses a regex value' do
      input = '/^n/'
      parser = described_class.new.values
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end

    it 'parses a quote value' do
      values = [%("double"), "'single'", %("double quotes"), %('single quotes')]
      values.each do |v|
        parser = described_class.new.values
        tree = parser.parse_with_debug(v)
        expect(tree).not_to be_nil
      end
    end
  end

  describe '#value_ors' do
    it 'parses combined values' do
      values = ['a|b', 'a&b', '(a)', 'a|(b&c)', '(a&b)|(c&d)']
      values.each do |v|
        parser = described_class.new.value_ors
        tree = parser.parse_with_debug(v)
        expect(tree).not_to be_nil
      end
    end
  end

  describe '#pair' do
    it 'parses a pair' do
      keywords = %w[a b c]
      operators = [':', '!', '>', '<', '<=', '>=']
      values = ['a', '/.*[^ab]$/', %{(a|"b")&(c|' d ')}]
      keywords.each do |k|
        operators.each do |o|
          values.each do |v|
            parser = described_class.new.pair
            tree = parser.parse_with_debug("#{k}#{o}#{v}")
            expect(tree).not_to be_nil
          end
        end
      end
    end
  end

  describe '#query' do
    it 'parses a query' do
      input = %(f:weyland-consortium t!"operation" n<=1)
      parser = described_class.new.query
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end

    it 'parses a query and some words' do
      input = %(a b test run f:weyland-consortium t!"operation" n<=1)
      parser = described_class.new.query
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end
  end

  describe '#bare_string' do
    it 'parses a bare string' do
      input = %(hello-world)
      parser = described_class.new.bare_string
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end
  end

  describe '#quoted_string' do
    it 'parses a quoted string' do
      input = %("hello world")
      parser = described_class.new.quoted_string
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end
  end

  describe '#root parser' do
    it 'parses a query' do
      input = %(f:weyland-consortium t!"operation" n<=1)
      parser = described_class.new
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end

    it 'parses a bare word' do
      input = %( siphon      )
      parser = described_class.new
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end

    it 'parses a quoted word' do
      input = %( "sure gamble")
      parser = described_class.new
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end

    it 'parses strings' do
      input = %( "sure gamble"         diversion         )
      parser = described_class.new
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end

    it 'parses a query and some words' do
      input = %("bean" f:weyland-consortium t!"operation"   royalties  n<=1 )
      parser = described_class.new
      tree = parser.parse_with_debug(input)
      expect(tree).not_to be_nil
    end
  end

  describe '#string' do
    it 'parses a string' do
      inputs = [%("sure gamble"), %(diversion)]
      inputs.each do |s|
        parser = described_class.new.string
        tree = parser.parse_with_debug(s)
        expect(tree).not_to be_nil
      end
    end
  end
end

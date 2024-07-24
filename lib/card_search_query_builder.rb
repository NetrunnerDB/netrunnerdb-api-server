# frozen_string_literal: true

require_relative 'search_query_builder'

# Builds search query SQL for Card searches.
class CardSearchQueryBuilder < SearchQueryBuilder
  # Filter to only the Card fields.
  @fields = @@full_fields.select { |f| f.sql.key?(:c) }.map do |f|
    FieldData.new(f.type, f.sql[:c], f.keywords, f.documentation)
  end
end

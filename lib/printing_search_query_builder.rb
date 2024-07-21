# frozen_string_literal: true

require_relative 'search_query_builder'

# Builds search query SQL for Printing searches.
class PrintingSearchQueryBuilder < SearchQueryBuilder
  # Filter to only the Printing fields.
  @fields = @@full_fields.select { |f| f.sql.key?(:p) }.map do |f|
    FieldData.new(f.type, f.sql[:p], f.keywords, f.documentation)
  end
end

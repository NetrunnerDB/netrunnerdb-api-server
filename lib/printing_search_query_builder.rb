require_relative 'search_query_builder'

class PrintingSearchQueryBuilder < SearchQueryBuilder

  # Filter to only the Printing fields.
  @fields = @@full_fields.select{|f| f.sql.has_key?(:p)}.map{|f|
    FieldData.new(f.type, f.sql[:p], f.keywords, f.documentation)
  }

end

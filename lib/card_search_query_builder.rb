require_relative 'search_query_builder'

class CardSearchQueryBuilder < SearchQueryBuilder

  # Filter to only the Card fields.
  @fields = @@full_fields.select{|f| f.sql.has_key?(:c)}.map{|f|
    FieldData.new(f.type, f.sql[:c], f.keywords, f.documentation)
  }

end

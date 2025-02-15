# frozen_string_literal: true

Graphiti.configure do |config|
  config.pagination_links = true
  config.cache_rendering = true
end

Graphiti.cache = ::Rails.cache

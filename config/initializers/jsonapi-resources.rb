JSONAPI.configure do |config|
  config.json_key_format = :underscored_key
  config.route_format = :underscored_route

  config.default_paginator = :offset

  config.default_page_size = 100
  # Allow a very large max page size in order to allow "give me all the things" calls.
  config.maximum_page_size = 10000
end

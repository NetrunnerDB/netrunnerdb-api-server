JSONAPI.configure do |config|
  config.json_key_format = :underscored_key
  config.route_format = :underscored_route

  config.default_paginator = :offset

  config.default_page_size = 100
  config.maximum_page_size = 1000 
end

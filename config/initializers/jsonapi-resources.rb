JSONAPI.configure do |config|
  config.default_paginator = :offset

  config.default_page_size = 100
  config.maximum_page_size = 1000 
end

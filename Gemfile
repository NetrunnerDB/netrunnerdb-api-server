source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.1"

# Gems that have trouble with native packages on alpine.
gem 'google-protobuf', force_ruby_platform: true
gem 'nokogiri', force_ruby_platform: true

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", ">= 7.0.7.1"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6"

gem "parslet"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'rack', '~> 2.2'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

# Used for our import of the card data.
gem "activerecord-import"

# Base for our API.
gem 'jsonapi-resources'

# Views
gem 'scenic'

gem "sprockets-rails"
gem 'rspec_api_documentation'
gem "apitome"
gem 'jwt'

# Observability and monitoring via OpenTelemetry.
gem 'opentelemetry-sdk'
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-all'

group :development, :test do
  gem "brakeman", "~> 5.2"
  gem "bundler-audit", "~> 0.9.0"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'simplecov-cobertura'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

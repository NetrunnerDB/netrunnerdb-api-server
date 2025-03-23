# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.3.6'

# Gems that have trouble with native packages on alpine.
gem 'google-protobuf', force_ruby_platform: true
gem 'nokogiri', force_ruby_platform: true

gem 'rails', '~> 7'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.4'

gem 'parslet'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'rack', '~> 2.2'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '2.0.0'

# Used for our import of the card data.
gem 'activerecord-import'

# Base for our JSON API.
gem 'graphiti'
gem 'graphiti-rails'
gem 'kaminari', '~> 1.0'
gem 'ostruct'
gem 'responders'

# Views
gem 'scenic'

gem 'apitome'
gem 'jwt'
gem 'rspec_api_documentation'
gem 'sprockets-rails'

# Observability and monitoring via OpenTelemetry.
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-all'
gem 'opentelemetry-sdk'

# for review imports from NRDBc
gem 'reverse_markdown'

group :development, :test do
  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit', '~> 0.9.0'
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'graphiti_spec_helpers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'simplecov'
  gem 'simplecov-cobertura'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

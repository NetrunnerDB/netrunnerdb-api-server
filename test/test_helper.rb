ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "simplecov"
require 'simplecov-cobertura'
SimpleCov.coverage_dir 'coverage/unit'
SimpleCov.enable_coverage :branch
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/test/'
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Resources', 'app/resources'
  add_group 'Libraries', 'lib'
  add_group 'Spec', 'spec'
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

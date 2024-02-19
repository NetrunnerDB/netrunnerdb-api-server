require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
# Disable this for now.
#    if ['production', 'development'].include?(ENV['RAILS_ENV'])
#        c.use_all() # enables all instrumentation!
#    end
end

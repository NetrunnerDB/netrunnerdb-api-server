# frozen_string_literal: true

require 'optparse'
require 'json'

namespace :krakend do # rubocop:disable Metrics/BlockLength
  desc 'generate krakend API gateway config for the API.'

  def build_base_config(api_url, _jwk_url) # rubocop:disable Metrics/MethodLength
    # Base config, including API documentation endpoints.
    {
      'version' => 3,
      'name' => 'NRDB v3 API',
      'timeout' => '5s',
      'output_encoding' => 'json',
      'extra_config' => {
        'security/cors' => {
          'allow_origins' => [
            '*'
          ],
          'expose_headers' => %w[
            Content-Length
            Accept-Language
          ],
          'max_age' => '12h',
          'allow_methods' => %w[
            GET
            HEAD
            POST
            DELETE
            PATCH
          ],
          'allow_credentials' => true,
          'allow_headers' => %w[
            Accept-Language
            Authorization
            X-Forwarded-For
            X-Forwarded-Host
            X-Forwarded-Proto
          ]
        }
      },
      'endpoints' => [
        {
          "endpoint": '/',
          "output_encoding": 'no-op',
          "backend": [
            {
              "url_pattern": '/api/docs',
              "extra_config": {
                "plugin/http-client": {
                  "name": 'no-redirect'
                }
              },
              "encoding": 'no-op',
              "sd": 'static',
              "method": 'GET',
              "disable_host_sanitize": false,
              "host": [api_url]
            }
          ],
          "input_headers": %w[
            Authorization
            Content-Length
            Content-Type
            X-Forwarded-For
            X-Forwarded-Host
            X-Forwarded-Proto
          ]
        },
        {
          "endpoint": '/assets/apitome/{resource}',
          "output_encoding": 'no-op',
          "backend": [
            {
              "host": [api_url],
              "url_pattern": '/assets/apitome/{resource}',
              "encoding": 'no-op',
              "sd": 'static'
            }
          ],
          "input_headers": %w[
            Authorization
            Content-Length
            Content-Type
            X-Forwarded-For
            X-Forwarded-Host
            X-Forwarded-Proto
          ]
        },
        {
          "endpoint": '/assets/apitome/highlight_themes/{theme}',
          "output_encoding": 'no-op',
          "backend": [
            {
              "host": [api_url],
              "url_pattern": '/assets/apitome/highlight_themes/{theme}',
              "encoding": 'no-op',
              "sd": 'static'
            }
          ],
          "input_headers": %w[
            Authorization
            Content-Length
            Content-Type
            X-Forwarded-For
            X-Forwarded-Host
            X-Forwarded-Proto
          ]
        },
        {
          "endpoint": '/api/docs',
          "output_encoding": 'no-op',
          "backend": [
            {
              "host": [api_url],
              "url_pattern": '/api/docs',
              "encoding": 'no-op',
              "sd": 'static'
            }
          ],
          "input_headers": %w[
            Authorization
            Content-Length
            Content-Type
            X-Forwarded-For
            X-Forwarded-Host
            X-Forwarded-Proto
          ]
        }
      ]
    }
  end

  # Example rate limiting config. Not enabled right now because it takes base memory usage from 25m to over a gig.
  #      "extra_config": {
  #        "qos/ratelimit/router": {
  #          "client_max_rate": 5,
  #          "strategy": "ip"
  #        }
  #      },
  def build_base_endpoint(api_url, url, method)
    {
      'endpoint' => url,
      'method' => method,
      'backend' => [
        {
          "method": method,
          'host' => [api_url],
          'url_pattern' => url
        }
      ],
      'input_query_strings' => ['*'],
      "input_headers": %w[
        Authorization
        Content-Length
        Content-Type
        X-Forwarded-For
        X-Forwarded-Host
        X-Forwarded-Proto
      ]
    }
  end

  def build_protected_endpoints(api_url, jwk_url, url_base, methods)
    endpoints = []
    methods.each do |m|
      endpoint = build_base_endpoint(api_url, url_base, m)
      endpoint['extra_config'] = {
        'auth/validator' => {
          'alg' => 'RS256',
          'jwk_url' => jwk_url,
          'disable_jwk_security' => true
        }
      }
      endpoints << endpoint
    end
    endpoints
  end

  def build_public_endpoints(api_server_host, url_base, methods)
    endpoints = []
    methods.each do |m|
      endpoint = build_base_endpoint(api_server_host, url_base, m)
      endpoint['cache_ttl'] = '1h'
      endpoints << endpoint
    end
    endpoints
  end

  task :generate, %i[api_server_host jwk_url] => [:environment] do |_t, args|
    args.with_defaults(api_server_host: 'http://nrdb_api_server:3000')
    args.with_defaults(jwk_url: 'http://keycloak:8080/realms/nullsignal/protocol/openid-connect/certs')

    config = build_base_config(args[:api_server_host], args[:jwk_url])
    routes = {}
    Rails.application.routes.routes.each do |route|
      k = route.path.spec.to_s.gsub(/\(\.:format\)/, '').gsub(%r{/:(\w+)}, '/{\\1}')
      k = k.gsub(%r{/(\w+)s/{id}}, '/\\1s/{\\1_id}') if k.ends_with?('{id}')
      next unless k.starts_with?('/api/v3')

      routes[k] = [] unless routes.key?(k)
      routes[k] << route.verb
    end

    routes.each do |route, methods|
      if route.starts_with?('/api/v3/private')
        config['endpoints'].concat(build_protected_endpoints(args[:api_server_host], args[:jwk_url], route, methods))
      else
        config['endpoints'].concat(build_public_endpoints(args[:api_server_host], route, methods))
      end
    end

    puts JSON.pretty_generate(config)
  end
end

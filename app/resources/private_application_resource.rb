# frozen_string_literal: true

# PrivateApplicationResource is similar to ApplicationRecord - a base class that
# holds configuration/methods for subclasses.
# All Private Resources should inherit from PrivateApplicationResource.
class PrivateApplicationResource < Graphiti::Resource
  # Use the ActiveRecord Adapter for all subclasses.
  # Subclasses can still override this default.
  self.abstract_class = true
  self.adapter = Graphiti::Adapters::ActiveRecord
  self.base_url = Rails.application.routes.default_url_options[:host]
  # Default to the public endpoint namespace.
  self.endpoint_namespace = '/api/v3/private'
  self.autolink = true
  link(:self) { |resource| "#{endpoint[:url]}/#{resource.id}" } if endpoint[:actions].include?(:show)
end

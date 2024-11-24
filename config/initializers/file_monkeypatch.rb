# frozen_string_literal: true

# Backwards compatibility for File.exists? until rspec_api_documentation is updated.
class File
  class << self
    alias exists? exist?
  end
end

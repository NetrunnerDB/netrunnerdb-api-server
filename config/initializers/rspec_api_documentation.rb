# Work around an issue with Rack that is mucking with the encoding
# and preventing responses from showing up in our docs.
module RspecApiDocumentation
  class RackTestClient < ClientBase
    def response_body
      last_response.body.encode("utf-8")
    end
  end
end
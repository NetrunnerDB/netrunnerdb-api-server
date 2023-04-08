# Inspects the HTTP Authorization header for a Bearer JWT token and
# populates the @auth_token_payload instance variable with the JWT payload.
# This does no signature verification of the JWT, expecting a gateway or
# proxy to have done that already.
# If the payload cannot be parsed or does not have a preferred_username
# attribute, a 401 Unauthorized response with an empty JSON body will be
# returned.
# All private API endpoints should include this concern and can rely on the
# preferred_username to represent the user.
module JwtAuthorizationConcern
  extend ActiveSupport::Concern

  included do
    before_action :check_token
  end

  private

  def check_token
    @auth_token_payload = nil
    @current_user = nil

    jwt = nil

    auth_header = request.headers['Authorization']
    if !auth_header.nil?
      m = auth_header.match(/^Bearer (.*)$/)
      if m && m.captures.length == 1
        pieces = m.captures[0].split('.')
        if pieces.length == 3
          begin
              jwt = JSON.parse(Base64.decode64(pieces[1]))
              if !jwt.has_key?('preferred_username')
                jwt = nil
              else
                username = jwt['preferred_username']
                get_or_insert_user(username)
              end
          rescue JSON::ParserError
              jwt = nil
          end
        end
      end
    end
    if jwt.nil?
      return render json: {}, :status => :unauthorized
    end
    @auth_token_payload = jwt
  end

  def get_or_insert_user(username)
    user = nil
    begin
      user = User.find(username)
    rescue ActiveRecord::RecordNotFound
      user = User.new
      user.id = username
      user.save
    end
    @current_user = user
  end
end

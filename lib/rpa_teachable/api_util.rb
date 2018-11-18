require 'httparty'

module RPATeachable
  module APIUtil
    BASE_URL = 'base_url' #http://todoable.teachable.tech/api/authenticate
    AUTH_ENDPOINT = '/api/authenticate'

    class << self
      attr_accessor :auth_token

      def post(endpoint, body)
        response = with_reauthenticate_retry do
          HTTParty.post(
            BASE_URL + endpoint,
            headers: json_headers.merge(auth_header),
            body: body
          )
        end

        JSON.parse(response.body)
      end

      private

      def with_reauthenticate_retry(&blk)
        response = blk.call
        if response.status == 401
          refresh_auth_token
          response = blk.call
        end

        response
      end

      def json_headers
        {
          Accept: 'application/json',
          "Content-Type": 'application/json'
        }
      end

      def auth_header
        ensure_auth_token_present
        { Authorization: "Token #{auth_token}" }
      end

      def ensure_auth_token_present
        refresh_auth_token if auth_token.nil?
      end

      def refresh_auth_token
        response = HTTParty.post(BASE_URL + AUTH_ENDPOINT,
          headers: json_headers,
          basic_auth: {
            username: RPATeachable.user_name,
            password: RPATeachable.password
          }
        )
        byebug
        raise AuthenticationError if response.status == 401

        self.auth_token = response
      end
    end
  end
end

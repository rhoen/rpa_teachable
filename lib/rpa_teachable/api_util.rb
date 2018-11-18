require 'httparty'

module RPATeachable
  module APIUtil
    BASE_URL = 'base_url' #http://todoable.teachable.tech/api/authenticate
    AUTH_ENDPOINT = '/api/authenticate'

    class << self
      attr_accessor :auth_token

      def get(url)
        response = httparty_method(:get, url)
        JSON.parse(response.body, symbolize_name: true)
      end

      def post(url, body)
        response = httparty_method(:post, url, body: body)
        JSON.parse(response.body, symbolize_name: true)
      end

      def delete(url)
        httparty_method(:delete, url)
        true
      end

      def put(url)
        response = httparty_method(:put, url)
        JSON.parse(response.body, symbolize_name: true)
      end

      def patch(url, body)
        response = httparty_method(:patch, url, body: body)
        JSON.parse(response.body, symbolize_name: true)
      end

      private

      def httparty_method(method, url, opts = {})
        with_reauthenticate_retry do
          httparty_options = api_request_headers.merge(opts)
          HTTParty.send(
            method,
            url,
            httparty_options
          )
        end
      end

      def api_request_headers
        { headers: json_headers.merge(auth_header) }
      end

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
        { Authorization: "Token token=#{auth_token}" }
      end

      def ensure_auth_token_present
        refresh_auth_token if auth_token.nil?
      end

      def refresh_auth_token
        if RPATeachable.user_name.nil? || RPATeachable.password.nil?
          raise CredentialsNotSetError
        end
        response = HTTParty.post(BASE_URL + AUTH_ENDPOINT,
          headers: json_headers,
          basic_auth: {
            username: RPATeachable.user_name,
            password: RPATeachable.password
          }
        )

        handle_errors(response)

        self.auth_token = JSON.parse(response.body)['token']
      end

      def handle_errors(response)
        raise AuthenticationError if response.status == 401
        raise UnprocessableError.new(response.body) if response.status == 422
        raise ContactProviderError.new(response.body) if response.status == 500
      end
    end
  end
end

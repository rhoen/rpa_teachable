require 'httparty'

module RPATeachable
  module APIUtil
    BASE_URL = 'http://todoable.teachable.tech/api'
    AUTH_ENDPOINT = '/authenticate'

    class << self
      attr_accessor :auth_token

      def get(url)
        response = httparty_method(:get, url)
        JSON.parse(response.body, symbolize_names: true)
      end

      def post(url, body)
        response = httparty_method(:post, url, body: body.to_json)
        JSON.parse(response.body, symbolize_names: true)
      end

      def delete(url)
        httparty_method(:delete, url)
        true
      end

      def put(url)
        response = httparty_method(:put, url)
        true
      end

      def patch(url, body)
        response = httparty_method(:patch, url, body: body.to_json)
        JSON.parse(response.body, symbolize_names: true)
      end

      private

      def httparty_method(method, url, opts = {})
        response = with_reauthenticate_retry do
          httparty_options = api_request_headers.merge(opts)
          HTTParty.send(
            method,
            url,
            httparty_options
          )
        end

        handle_errors(response)
        response
      end

      def api_request_headers
        { headers: json_headers.merge(auth_header) }
      end

      def with_reauthenticate_retry(&blk)
        response = blk.call
        if response.code == 401
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
        raise AuthenticationError if response.code == 401
        raise UnprocessableError.new(response.body) if response.code == 422
        if response.code == 500
          raise ApiServerError.new(
            response: response.body,
            request: response.request.inspect
          )
        end
      end
    end
  end
end

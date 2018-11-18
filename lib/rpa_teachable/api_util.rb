require 'httparty'

module RPATeachable
  module APIUtil
    BASE_URL = 'base_url' #http://todoable.teachable.tech/api/authenticate
    AUTH_ENDPOINT = '/api/authenticate'

    class << self
      attr_accessor :auth_token

      def get(url)
        response = with_reauthenticate_retry do
          HTTParty.get(
            url,
            headers: json_headers.merge(auth_header)
          )
        end

        JSON.parse(response.body)
      end

      def post(url, body)
        response = with_reauthenticate_retry do
          HTTParty.post(
            url,
            headers: json_headers.merge(auth_header),
            body: body
          )
        end

        JSON.parse(response.body, symbolize_name: true)
      end

      def delete(url)
        response = with_reauthenticate_retry do
          HTTParty.delete(
            url,
            headers: json_headers.merge(auth_header)
          )
        end

        true
      end

      def put(url)
        response = with_reauthenticate_retry do
          HTTParty.put(
            url,
            headers: json_headers.merge(auth_header),
            body: body
          )
        end

        JSON.parse(response.body)
      end

      def patch(url, body)
        response = with_reauthenticate_retry do
          HTTParty.patch(
            url,
            headers: json_headers.merge(auth_header),
            body: body
          )
        end

        JSON.parse(response.body)
      end

      private

      # def httparty_method(method, endpoint, opts)
      #   httparty_options = headers: json_headers.merge(auth_header).merge(opts)
      #   response = with_reauthenticate_retry do
      #     HTTParty.send(
      #       method,
      #       BASE_URL + endpoint,
      #       httparty_options
      #     )
      #   end
      #
      #   JSON.parse(response.body)
      # end

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

        raise AuthenticationError if response.status == 401

        self.auth_token = JSON.parse(response.body)['token']
      end
    end
  end
end

describe RPATeachable::APIUtil do
  describe '#get' do
    let(:auth_token) { 'some_token' }
    let(:auth_body) do
      { token: auth_token }.to_json
    end
    let(:auth_url) do
      RPATeachable::APIUtil::BASE_URL +
      RPATeachable::APIUtil::AUTH_ENDPOINT
    end
    let(:fetch_url) do
      RPATeachable::APIUtil::BASE_URL +
      '/fetch_endpoint'
    end
    let(:fetch_body) { { some: :body }.to_json }
    let(:fetch_response) do
      [double('fetch_response', code: 200, body: fetch_body)]
    end

    before do
      RPATeachable.user_name = nil
      RPATeachable.password = nil
      RPATeachable::APIUtil.auth_token = nil
      allow(HTTParty).to receive(:get).and_return(*fetch_response)
      allow(HTTParty).to receive(:post).and_return(*auth_response)
    end

    context 'returns code 422' do
      let(:fetch_response) { [double('fetch_response', code: 422)] }
      it 'raises UnprocessableError' do
        expect { described_class.get(fetch_url) }.to raise_error(
          UnprocessableError
        )
      end
    end

    context 'returns code 500' do
      let(:fetch_response) { [double('fetch_response', code: 500)] }
      it 'raises ContactProviderError' do
        expect { described_class.get(fetch_url) }.to raise_error(
          ContactProviderError
        )
      end
    end

    context 'with credentials' do
      let(:user_name) { 'user_name' }
      let(:password) { 'password' }
      before do
        RPATeachable.user_name = user_name
        RPATeachable.password = password
      end

      let(:auth_response) do
        [double('response', code: 200, body: auth_body)]
      end

      context 'auth token not present' do
        it 'generates an auth token' do
          described_class.get(fetch_url)
          expect(HTTParty).to have_received(:post).with(
            auth_url,
            hash_including(
              basic_auth: { username: user_name, password: password }
            )
          )
        end
      end

      context 'auth token present and not expired' do
        before do
          described_class.auth_token = auth_token
        end

        it 'calls get on HTTParty with the auth token' do
          described_class.get(fetch_url)
          expect(HTTParty).to have_received(:get).once.with(
            fetch_url,
            hash_including(
              headers: hash_including(
                { Authorization: "Token token=#{auth_token}" }
              )
            )
          )
        end
      end

      context 'auth token present and expired' do
        let(:new_token) { 'new_token' }
        let(:new_auth_body) { { token: new_token }.to_json }
        let(:fetch_response) do
          [
            double('unauthorized', code: 401),
            double('authorized', code: 200, body: fetch_body)
          ]
        end
        let(:auth_body) do
          { token: new_token }.to_json
        end
        before do
          described_class.auth_token = auth_token
        end

        it 'reauthenticates' do
          described_class.get(fetch_url)
          expect(HTTParty).to have_received(:post).with(auth_url, anything).once
        end

        it 'calls get on HTTParty with new auth token' do
          described_class.get(fetch_url)
          expect(HTTParty).to have_received(:get).with(
            fetch_url,
            headers: hash_including({Authorization: "Token token=#{new_token}"})
          )
        end
      end

      context 'credentials rejected' do
        let(:auth_response) do
          [double('unauthorized', code: 401)]
        end

        it 'raises error' do
          expect {described_class.get(fetch_url)}.to raise_error(
            RPATeachable::AuthenticationError
          )
        end
      end
    end

    context 'without credentials' do
      let(:auth_response) do
        [double('unauthorized', code: 401)]
      end

      it 'raises error' do
        expect {described_class.get(fetch_url)}.to raise_error(
          RPATeachable::CredentialsNotSetError
        )
      end
    end
  end
end

describe RPATeachable::APIUtil do
  before do
    allow(HTTParty).to receive(:put)
    allow(HTTParty).to receive(:patch)
    allow(HTTParty).to receive(:delete)
  end

  shared_examples :authentication do |method, *args|
    let(:auth_token) { 'some_token' }
    let(:auth_body) do
      { token: auth_token }.to_json
    end
    let(:auth_url) do
      RPATeachable::APIUtil::BASE_URL +
      RPATeachable::APIUtil::AUTH_ENDPOINT
    end

    before do
      allow(HTTParty).to receive(:post).with(auth_url).and_return(auth_response)
    end

    context 'with credentials' do
      let(:user_name) { 'user_name' }
      let(:password) { 'password' }
      before do
        RPATeachable.user_name = user_name
        RPATeachable.password = password
      end

      let(:auth_response) do
        double('response', status: 200, body: auth_body)
      end

      describe "#{method}" do
        context 'auth token not present' do
          it 'generates an auth token' do
            described_class.send(method, *args)
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

          it "calls #{method} on HTTParty with the auth token" do
            described_class.send(method, *args)
            expect(HTTParty).to have_received(method).once.with(
              anything,
              hash_including(
                headers: hash_including(
                  { Authorization: "Token #{auth_token}" }
                )
              )
            )
          end
        end

        context 'auth token present and expired' do
          let(:new_auth_body) { { token: 'new_token' }.to_json }
          before do
            described_class.auth_token = auth_token
            allow(HTTParty).to receive(:post).with(args[0])
              .and_return(
                double('unauthorized', status: 401),
                double('authorized', status: 200, body: new_auth_body)
              )
          end

          it 'reauthenticates' do
            described_class.send(method, *args)
            expect(HTTParty).to have_received(:post).with(auth_url).once
          end

          it "calls #{method} on HTTParty with new auth token" do
            described_class.send(method, *args)
            expect(HTTParty).to have_received(method).once.with(
              headers: hash_including({'Authorization' => "Token #{new_token}"})
            )
          end
        end

        context 'credentials rejected' do
          let(:auth_response) do
            double('response', status: 401)
          end

          it 'raises error' do
            expect {described_class.send(method, *args)}.to raise_error(
              RuntimeError
            )
          end
        end
      end
    end

    context 'without credentials' do
      let(:auth_response) do
        double('response', status: 401)
      end

      it 'raises error' do
        expect {described_class.send(method, *args)}.to raise_error(RuntimeError)
      end
    end
  end

  describe '#post' do
    create_endpoint = 'create_endpoint'
    before do
      allow(HTTParty).to receive(:post).with(create_endpoint).and_return(
        double('create_resonse', status: 201)
      )
    end
    it_behaves_like :authentication, :post, create_endpoint, {some: :body}
  end

  describe '#put'
  describe '#patch'
  describe '#delete'
end

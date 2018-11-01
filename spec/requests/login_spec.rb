require_relative '../spec_utils'

describe 'GET /login' do
  it 'is successful' do
    get '/login'
    expect(last_response).to be_ok
  end
end

describe 'POST /login' do
  let(:user) do
    double(
      'User',
      id: '1',
      email: 'bob@twilio.com',
      password_hash: 'hash',
      password_salt: 'salt',
      authy_id: '1001'
    )
  end

  context 'when the credentials are correct' do
    it 'responds with onetouch or sms' do
      allow(User).to receive(:first).and_return(user)

      allow_any_instance_of(TwoFactorAuth::App)
        .to receive(:valid_password?)
        .with('secret', 'hash')
        .and_return(true)

      httpResponse = OpenStruct.new({
                         'status' => 200,
                         'body' => {
                             'success' => true,
                             'status' => {
                                 'registered' => true,
                                 'devices' => ['iphone']
                             }
                         }.to_json
                     })
      response = Authy::Response.new(httpResponse)

      allow(Authy::API)
          .to receive(:user_status)
          .and_return(response)

      allow(Authy::OneTouch)
        .to receive(:send_approval_request)
        .and_return({"success" => true})

      allow(user).to receive(:update!).with(authy_status: :onetouch)

      post '/login', email: 'bob@example.com', password: 'secret'

      expect(last_response.body).to eq("onetouch")
      expect(last_response).to be_ok
    end
  end

  context 'when the credentials are incorrect' do
    it 'responds with unauthorized' do
      allow(User).to receive(:first).and_return(user)

      allow_any_instance_of(TwoFactorAuth::App)
        .to receive(:valid_password?)
        .and_return(false)

      post '/login', email: 'bob@example.com', password: 'secret'

      expect(last_response.body).to eq("unauthorized")
      expect(last_response).to be_ok
    end
  end
end

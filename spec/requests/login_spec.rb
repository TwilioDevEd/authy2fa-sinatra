require_relative '../spec_helper'

describe 'GET /login' do
  it 'is successful' do
    get '/login'
    expect(last_response).to be_ok
  end
end

describe 'POST /login' do
  it 'authenticate the user when the credentials are correct' do
    user = double(
      'User',
      id: '1',
      username: 'bob',
      email: 'bob@twilio.com',
      password_hash: 'hash',
      password_salt: 'salt',
      authy_id: '1001'
    )

    allow(User).to receive(:first).and_return(user)
    allow(UserAuthenticator).to receive(:authenticate)
      .with('hash', 'salt', 'secret').and_return(true)
    allow(Authy::OneTouch).to receive(:send_approval_request)
      .and_return({"success" => true})
    allow(SessionManager).to receive(:init_session)

    allow(user).to receive(:update!).with(authy_status: :onetouch)

    post '/login', email: 'bob@example.com', password: 'secret'

    expect(last_response.body).to eq("onetouch")
    expect(last_response).to be_ok
  end
end

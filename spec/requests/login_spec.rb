require_relative '../spec_helper'

describe 'GET /login' do
  it 'is successful' do
    get '/login'
    expect(last_response.status).to eq 200
  end
end

describe 'POST /login' do
  it 'authenticate the user when the credentials are correct' do
    user = double('User', username: 'bob', password_hash: 'hash', password_salt: 'salt')

    allow(User).to receive(:first).and_return(user)
    allow(UserAuthenticator).to receive(:authenticate)
      .with('hash', 'salt', 'secret').and_return(true)

    post '/login', email: 'bob@example.com', password: 'secret'

    expect(last_response).to be_redirect
    expect(last_response.status).to eq 302
  end
end

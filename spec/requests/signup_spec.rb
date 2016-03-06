require_relative '../spec_helper'

describe 'GET /signup' do
  it 'is successful' do
    get '/signup'
    expect(last_response).to be_ok
  end
end

describe 'POST /signup' do
  before do
    user_attributes = {
      name: 'bob',
      email: 'bob@example.com',
      password: 'secret',
      country_code: '1',
      phone_number: '555 5555'
    }

    authy = double('Authy', id: '101')
    allow(Authy::API).to receive(:register_user).and_return(authy)

    post '/signup', user_attributes
  end

  it 'creates a user' do
    bob = User.last
    expect(bob.email).to eq 'bob@example.com'
  end

  it 'updates authy_id' do
    bob = User.last
    expect(bob.authy_id).to eq '101'
  end

  it 'redirect to protected content' do
    expect(last_response).to be_redirect
    expect(last_response.location).to include '/protected'
  end
end

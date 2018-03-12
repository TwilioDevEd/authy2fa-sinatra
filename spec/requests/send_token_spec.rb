require_relative '../spec_utils'

describe 'POST /send-token' do
  it 'request a sms token' do
    user = User.create!(authy_id: '101')
    allow_any_instance_of(TwoFactorAuth::App).to receive(:current_user) { user.id }
    allow(Authy::API).to receive(:request_sms).with(id: user.authy_id)

    post '/send-token'

    expect(last_response).to be_ok
    expect(last_response.body).to eq('Token has been sent')
  end
end

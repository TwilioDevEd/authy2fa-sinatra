require_relative '../spec_utils'

describe 'POST /authy/callback' do
  context 'when the callback comes from Authy' do
    it 'returns approved' do
      bob = User.create!(authy_id: '101')
      allow_any_instance_of(TwoFactorAuth::App).to receive(:authenticate_request!)

      post '/authy/callback', '{"authy_id":"101","status":"approved"}'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('OK')
      expect(User.last.authy_status).to eq(:approved)
    end
  end

  context 'when the calback is authentic' do
    it 'returns denied' do
      post '/authy/callback', '{"authy_id":"101"}'

      expect(last_response).to be_redirect
      expect(last_response.location).to include '/login'
    end
  end
end

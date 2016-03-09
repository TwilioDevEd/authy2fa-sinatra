require_relative '../spec_helper'

describe 'POST /verify-token' do
  context 'when the token is valid' do
    it 'gets redirected to protected content' do
      user = User.create!(authy_id: '101')
      allow_any_instance_of(TwoFactorAuth::App)
        .to receive(:current_user) { user.id }
      allow(Authy::API)
        .to receive(:verify)
        .with(id: user.authy_id, token: '1234')
        .and_return(double('Token', :ok? => true))

      post '/verify-token', token: '1234'

      expect(last_response).to be_redirect
      expect(last_response.location).to include '/protected'
    end
  end

  context 'when the token is invalid' do
    it 'gets redirected to login' do
      user = User.create!(authy_id: '101')
      allow_any_instance_of(TwoFactorAuth::App)
        .to receive(:current_user) { user.id }
      allow(Authy::API)
        .to receive(:verify)
        .with(id: user.authy_id, token: '1234')
        .and_return(double('Token', :ok? => false))

      post '/verify-token', token: '1234'

      expect(last_response).to be_redirect
      expect(last_response.location).to include '/login'
    end
  end
end

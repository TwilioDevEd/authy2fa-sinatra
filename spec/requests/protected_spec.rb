require_relative '../spec_helper'

describe 'GET /protected' do
  context 'when the user is authenticated' do
    it 'access to protected content' do
      allow_any_instance_of(TwoFactorAuth::App).to receive(:authenticate!)

      user = User.create!(username: 'bob', phone_number: '555-5555')
      allow_any_instance_of(TwoFactorAuth::App).to receive(:current_user) { user.id }

      get '/protected'

      expect(last_response).to be_ok
      expect(last_response.body).to include user.username
    end
  end

  context 'when the user is not authenticated' do
    it 'gets redirected to login page' do
      get '/protected'

      expect(last_response).to be_redirect
      expect(last_response.location).to include '/login'
    end
  end
end

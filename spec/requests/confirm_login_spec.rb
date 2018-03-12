require_relative '../spec_utils'

describe 'POST /confirm-login' do
  context 'when the authy_status is approved' do
    it 'gets redirected to protected content' do
      user = User.create!(authy_status: :approved)
      allow_any_instance_of(TwoFactorAuth::App).to receive(:current_user) { user.id }

      post '/confirm-login'

      expect(last_response).to be_redirect
      expect(last_response.location).to include '/protected'
    end
  end

  context 'when the authy_status not approved' do
    it 'gets redirected to login' do
      user = User.create!(authy_status: :denied)
      allow_any_instance_of(TwoFactorAuth::App).to receive(:current_user) { user.id }

      post '/confirm-login'

      expect(last_response).to be_redirect
      expect(last_response.location).to include '/login'
    end
  end

  it 'resets authy_status' do
    user = User.create!(authy_status: :denied)
    allow_any_instance_of(TwoFactorAuth::App).to receive(:current_user) { user.id }

    post '/confirm-login'

    user = User.last
    expect(user.authy_status).to eq(:unverified)
  end
end

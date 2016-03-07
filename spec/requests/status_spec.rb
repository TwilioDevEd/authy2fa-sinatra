require_relative '../spec_helper'

describe 'POST /authy/status' do
  context 'when the status is approved' do
    it 'returns approved' do
      user = User.create!(authy_status: :approved)

      allow_any_instance_of(TwoFactorAuth::App).to receive(:current_user) { user.id }

      post '/authy/status'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('approved')
    end
  end

  context 'when the status is denied' do
    it 'returns denied' do
      user = User.create!(authy_status: :denied)

      allow_any_instance_of(TwoFactorAuth::App).to receive(:current_user) { user.id }

      post '/authy/status'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('denied')
    end
  end
end

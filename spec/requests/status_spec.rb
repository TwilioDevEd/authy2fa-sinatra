require_relative '../spec_helper'

describe 'POST /authy/status' do
  it 'foo' do
    user = double('User', authy_status: :approved)
    allow(User).to receive(:first).and_return(user)
    allow(Authentication).to receive(:user_id)

    post '/authy/status'

    expect(last_response.status).to eq 200
  end
end

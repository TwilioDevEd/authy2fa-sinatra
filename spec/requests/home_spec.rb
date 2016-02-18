require_relative '../spec_helper'

describe 'GET /' do
  before { get '/' }

  it 'is successful' do
    expect(last_response.status).to eq 200
  end
end

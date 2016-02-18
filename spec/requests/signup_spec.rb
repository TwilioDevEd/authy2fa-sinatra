require_relative '../spec_helper'

describe 'GET /signup' do
  before { get '/signup' }

  it 'is successful' do
    expect(last_response.status).to eq 200
  end
end

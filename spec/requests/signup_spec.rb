require_relative '../spec_helper'

describe 'GET /signup' do

  it 'is successful' do
    get '/signup'
    expect(last_response.status).to eq 200
  end
end

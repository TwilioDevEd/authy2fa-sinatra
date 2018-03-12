ENV['RACK_ENV'] = 'test'

require 'database_cleaner'
require_relative File.join('..', 'app')

RSpec.configure do |config|
  include Rack::Test::Methods

  database_url = 'postgres://localhost/authy2fa_sinatra_test'
  DataMapper.setup(:default, database_url)
  DataMapper.finalize
  User.auto_upgrade!

  config.formatter = :documentation
  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  def app
    TwoFactorAuth::App
  end
end

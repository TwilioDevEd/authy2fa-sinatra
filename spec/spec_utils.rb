ENV['RACK_ENV'] = 'test'
ENV['APP_ENV'] = 'test'

require 'database_cleaner'
require_relative File.join('..', 'app')

RSpec.configure do |config|
  config.include Rack::Test::Methods

  database_url = "sqlite3://#{Dir.pwd}/test.sqlite3"
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

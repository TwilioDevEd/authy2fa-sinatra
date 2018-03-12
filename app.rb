ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra/base'
require 'tilt/haml'
require 'authy'
require 'json'
require 'dotenv/load'

require_relative 'models/user'
require_relative 'helpers'
require_relative 'routes/signup'
require_relative 'routes/sessions'
require_relative 'routes/confirmation'

database_url = 'postgres://localhost/authy2fa_sinatra'
DataMapper.setup(:default, database_url)
DataMapper.finalize
User.auto_upgrade!

module TwoFactorAuth
  class App < Sinatra::Base
    enable :sessions

    set :root, File.dirname(__FILE__)

    helpers Helpers

    register Routes::Signup
    register Routes::Sessions
    register Routes::Confirmation

    get '/' do
      haml :home
    end

    get '/protected' do
      authenticate!

      @user = User.first(id: current_user)
      haml :protected
    end
  end
end

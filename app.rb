require 'sinatra/base'
require 'bcrypt'
require 'tilt/haml'

require_relative './models/user'
require_relative './lib/user_authenticator'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

database_url = 'postgres://localhost/authy2fa_sinatra'
DataMapper.setup(:default, database_url)
DataMapper.finalize

User.auto_upgrade!

module TwoFactorAuth
  class App < Sinatra::Base
    enable :sessions

    helpers do
      def authenticated?
        !session[:username].nil?
      end

      def username
        session[:username]
      end
    end

    set :root, File.dirname(__FILE__)

    get '/' do
      haml :home
    end

    get '/signup' do
      haml :signup
    end

    post '/signup' do
      username     = params[:name]
      email        = params[:email]
      password     = params[:password]
      country_code = params[:country_code]
      phone_number = params[:phone_number]

      password_salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(password, password_salt)

      user = User.create!(
        username:      username,
        email:         email,
        password_salt: password_salt,
        password_hash: password_hash,
        country_code:  country_code,
        phone_number:  phone_number,
        authy_id:      '',
        authy_status:  ''
      )

      p user

      session[:username] = username

      # Redirect to protected route
      haml '/'
    end

    get '/login' do
      haml :login
    end

    post '/login' do
      email    = params[:email]
      password = params[:password]

      # Find the user
      user = User.first(email: email)
      if user && UserAuthenticator.authenticate(
        user.password_hash, user.password_salt, password)
        session[:username] = user.username
        redirect "/" # Redirect to protected location
      end

      # You're not authorized. Add some error message.
      'error'
    end

    post '/logout' do
      session[:username] = nil
      redirect '/' # redirect to some unprotected area
    end
  end
end

require 'sinatra/base'
require 'bcrypt'
require 'tilt/haml'

require_relative './models/user'

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

      p password_salt
      p password_hash

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

    post '/login' do
      user = nil
      if user # Find a user with the username
        if user[:passwordhash] == BCrypt::Engine.hash_secret(params[:password], user[:salt])
          session[:username] = params[:username] # At this point the user is authenticated
          redirect "/"
        end
      end

      'error'
    end

    post '/logout' do
      session[:username] = nil
      redirect '/' # redirect to some unprotected area
    end
  end
end

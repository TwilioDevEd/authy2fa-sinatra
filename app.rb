require 'sinatra/base'
require 'bcrypt'
require 'tilt/haml'
require 'authy'
require 'json'

require_relative './models/user'
require_relative './lib/user_authenticator'
require_relative './lib/authentication'
require_relative './lib/session_manager'

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

    helpers Authentication
    helpers SessionManager

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

      Authy.api_key = ENV['AUTHY_API_KEY']

      authy = Authy::API.register_user(
        email: user.email,
        cellphone: user.phone_number,
        country_code: user.country_code
      )

      user.update(authy_id: authy.id)
      SessionManager.init_session(user.id)

      # Redirect to protected route
      haml '/protected'
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

        # The user is authenticated at this point
        Authy.api_key = ENV['AUTHY_API_KEY']
        one_touch = Authy::OneTouch.send_approval_request(
          id: user.authy_id,
          message: "Request to Login to Twilio demo app",
          details: { 'Email Address' => user.email }
        )

        status = one_touch["success"] ? :onetouch : :sms
        user.update!(authy_status: status)

        SessionManager.init_session(user.id)

        # Return the authy status
        status.to_s
      else
        "unauthorized"
      end
    end

    post '/logout' do
      SessionManager.destroy
      redirect '/' # redirect to some unprotected area
    end

    get '/protected' do
      authenticate!
    end

    post '/callback' do
      params       = JSON.parse(request.body.read)
      authy_id     = params["authy_id"]
      authy_status = params["status"]

      begin
        user = User.first(authy_id: authy_id)
        user.update(authy_status: authy_status)
      rescue => e
        puts e.message
      end

      'OK'
    end

    post '/authy/status' do
      user_id = Authentication.user_id
      user = User.first(id: user_id)

      user.authy_status.to_s
    end

    post '/confirm-login' do
      # Find pre-logged user
      authy_status = user.authy_status

      user.update(authy_status: :unverified)

      case authy_status
      when :approved
        # Login
      when :denied
        # Logout
      else
        # Logout
      end
    end
  end
end

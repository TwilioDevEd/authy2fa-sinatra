ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'sinatra/base'
require 'bcrypt'
require 'tilt/haml'
require 'authy'
require 'json'

require_relative 'models/user'
require_relative 'helpers'
require_relative 'lib/user_authenticator'
require_relative 'lib/request_authenticator'


database_url = 'postgres://localhost/authy2fa_sinatra'
DataMapper.setup(:default, database_url)
DataMapper.finalize
User.auto_upgrade!

module TwoFactorAuth
  class App < Sinatra::Base
    enable :sessions

    helpers TwoFactorAuth::Helpers

    set :root, File.dirname(__FILE__)

    get '/' do
      haml :home
    end

    get '/signup' do
      haml :signup
    end

    post '/signup' do
      password      = params[:password]
      password_salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(password, password_salt)

      user = User.create!(
        username:      params[:username],
        email:         params[:email],
        password_salt: password_salt,
        password_hash: password_hash,
        country_code:  params[:country_code],
        phone_number:  params[:phone_number]
      )

      Authy.api_key = ENV['AUTHY_API_KEY']
      authy = Authy::API.register_user(
        email: user.email,
        cellphone: user.phone_number,
        country_code: user.country_code
      )

      user.update!(authy_id: authy.id)
      init_session!(user.id)

      redirect '/protected'
    end

    get '/login' do
      haml :login
    end

    post '/login' do
      user = User.first(email: params[:email])
      if user && UserAuthenticator.authenticate(
        user.password_hash, user.password_salt, params[:password])

        Authy.api_key = ENV['AUTHY_API_KEY']
        one_touch = Authy::OneTouch.send_approval_request(
          id: user.authy_id,
          message: "Request to Login to Twilio demo app",
          details: { 'Email Address' => user.email }
        )

        status = one_touch["success"] ? :onetouch : :sms
        user.update!(authy_status: status)

        pre_init_session!(user.id)

        status.to_s
      else
        "unauthorized"
      end
    end

    get '/logout' do
      destroy_session!
      redirect '/login'
    end

    get '/protected' do
      authenticate!

      @user = User.first(id: current_user)
      haml :protected
    end

    post '/callback' do
      RequestAuthenticator.authenticate!(request, headers)

      request.body.rewind
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
      user = User.first(id: current_user)
      user.authy_status.to_s
    end

    post '/confirm-login' do
      user = User.first(id: current_user)
      authy_status = user.authy_status

      user.update(authy_status: :unverified)

      if authy_status == :approved
        init_session!(user.id)
        redirect "/protected"
      else
        destroy_session!
        redirect "/login"
      end
    end
  end
end

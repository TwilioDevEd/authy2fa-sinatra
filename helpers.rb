require 'active_support/all'
require 'base64'
require 'bcrypt'
require 'json'
require 'openssl'

module TwoFactorAuth
  module Helpers
    # Authentication
    def authenticate!
      redirect '/login' unless authenticated?
    end

    def authenticated?
      !!session[:user_id]
    end

    def current_user
      session[:pre_2fa_auth_user_id] || session[:user_id]
    end

    # Session Management
    def init_session!(user_id)
      session[:user_id] = user_id
    end

    def pre_init_session!(user_id)
      session[:pre_2fa_auth_user_id] = user_id
    end

    def destroy_session!
      session[:pre_2fa_auth_user_id] = nil
      session[:user_id] = nil
    end

    # Password Management
    def hash_password(plain_password)
      password_salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(plain_password, password_salt)

      [password_salt, password_hash]
    end

    def valid_password?(plain_password, password_hash)
      password_hash == BCrypt::Engine.hash_secret(plain_password, password_hash)
    end

    # Request Authentication
    def authenticate_request!(request)
      url            = request.url
      request_method = request.request_method
      nonce          = request.env['HTTP_X_AUTHY_SIGNATURE_NONCE']
      raw_params     = JSON.parse(request.body.read)
      sorted_params  = (Hash[raw_params.sort]).to_query

      data = "#{nonce}|#{request_method}|#{url}|#{sorted_params}"

      authy_api_key = ENV['AUTHY_API_KEY']
      digest = OpenSSL::HMAC.digest('sha256', authy_api_key, data)
      digest_in_base64 = Base64.encode64(digest)

      authy_signature          = (request.env['HTTP_X_AUTHY_SIGNATURE'])
      computed_authy_signature = digest_in_base64.strip

      redirect '/login' if authy_signature != computed_authy_signature
    end
  end
end

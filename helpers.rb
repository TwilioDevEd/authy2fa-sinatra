require 'bcrypt'

module TwoFactorAuth
  module Helpers
    # Authentication
    def authenticate!
      unless session[:user_id]
        redirect '/login'
      end
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

    def valid_password?(plain_password, password_hash, password_salt)
      password_hash == BCrypt::Engine.hash_secret(plain_password, password_hash)
    end
  end
end

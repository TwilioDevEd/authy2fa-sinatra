module Routes
  module Signup
    def self.registered(app)
      app.get '/signup' do
        haml :signup
      end

      app.post '/signup' do
        password_salt, password_hash = hash_password(params[:password])
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
    end
  end
end

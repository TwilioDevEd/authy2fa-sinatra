module Routes
  module Sessions
    def self.registered(app)
      app.get '/login' do
        haml :login
      end

      app.post '/login' do
        user = User.first(email: params[:email])
        if user && valid_password?(
          params[:password], user.password_hash, user.password_salt)

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

      app.get '/logout' do
        destroy_session!
        redirect '/login'
      end
    end
  end
end

require 'haml'

module Routes
  module Sessions
    def self.registered(app)
      app.get '/login' do
        haml(:login)
      end

      app.post '/login' do
        user = User.first(email: params[:email])
        if user && valid_password?(params[:password], user.password_hash)
          Authy.api_key = ENV['AUTHY_API_KEY']
          user_status = Authy::API.user_status(id: user.authy_id)
          puts user_status
          required_devices = ['iphone', 'android']
          registered_devices = user_status['status']['devices']

          if user_status['status']['registered'] \
            and (required_devices & registered_devices)
            Authy::OneTouch.send_approval_request(
              id: user.authy_id,
              message: 'Request to Login to Twilio demo app',
              details: { 'Email Address' => user.email }
            )

            status = :onetouch
          else
            Authy::API.request_sms(id: user.authy_id)
            status = :sms
          end
          user.update!(authy_status: status)

          pre_init_session!(user.id)

          status.to_s
        else
          'unauthorized'
        end
      end

      app.get '/logout' do
        destroy_session!
        redirect '/login'
      end
    end
  end
end

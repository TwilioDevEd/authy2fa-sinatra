module Routes
  module Confirmation
    def self.registered(app)
      app.post '/callback' do
        authenticate_request!(request)

        request.body.rewind
        params       = JSON.parse(request.body.read)
        authy_id     = params['authy_id']
        authy_status = params['status']

        begin
          user = User.first(authy_id: authy_id)
          user.update(authy_status: authy_status)
        rescue => e
          puts e.message
        end

        'OK'
      end

      app.post '/authy/status' do
        user = User.first(id: current_user)
        user.authy_status.to_s
      end

      app.post '/confirm-login' do
        user = User.first(id: current_user)
        authy_status = user.authy_status

        user.update(authy_status: :unverified)

        if authy_status == :approved
          init_session!(user.id)
          redirect '/protected'
        else
          destroy_session!
          redirect '/login'
        end
      end
    end
  end
end

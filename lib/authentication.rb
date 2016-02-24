module Authentication
  def authenticate!
    unless session[:user]
      redirect '/login'
    end
  end

  def authenticated?
    !session[:username].nil?
  end

  def username
    session[:username]
  end
end

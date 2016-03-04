module Authentication
  def authenticate!
    unless session[:user_id]
      redirect '/login'
    end
  end

  def authenticated?
    !session[:user_id].nil?
  end

  def pre_authenticated?
    !session[:pre_2fa_auth_user_id].nil?
  end

  def current_user
    session[:pre_2fa_auth_user_id] || session[:user_id]
  end
end

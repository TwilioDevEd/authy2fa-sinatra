module SessionManager
  def init_session(user_id)
    session[:user_id] = user_id
  end

  def pre_init_session!(user_id)
    session[:pre_2fa_auth_user_id] = user_id
  end

  def destroy
    session[:pre_2fa_auth_user_id] = nil
    session[:user_id] = nil
  end
end

class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: :create

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by(uid: auth.uid) do |u|
      u.name = auth.info.nickname
      u.avatar_url = auth.info.image
    end
    session[:user_id] = user.id
    session.delete(:try_mode) if session[:try_mode]
    session.delete(:try_datetime) if session[:try_datetime]
    redirect_to repositories_path, notice: "Signed in!"
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Signed out!", status: :see_other
  end
end

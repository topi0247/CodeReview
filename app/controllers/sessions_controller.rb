class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: :create

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by(uid: auth.uid) do |u|
      u.name = auth.info.nickname
      u.avatar_url = auth.info.image
    end
    session[:user_id] = user.id
    redirect_to repositories_path, notice: "ログインしました"
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "ログアウトしました", status: :see_other
  end
end

class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by(uid: auth.uid) do |u|
      u.name = auth.info.name
      u.avatar_url = auth.info.image
    end
    session[:user_id] = user.id
    redirect_to root_path, notice: "Signed in!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out!", status: :see_other
  end
end

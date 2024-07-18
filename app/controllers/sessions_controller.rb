class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: :create

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by(uid: auth.uid) do |u|
      u.name = auth.info.name
      u.avatar_url = auth.info.image
    end
    session[:user_id] = user.id
    session[:github_access_token] = request.env['omniauth.auth']['credentials']['token'].to_s
    redirect_to repositories_path, notice: "Signed in!"
  end

  def destroy
    session.delete(:user_id)
    session.delete(:github_access_token)
    redirect_to root_path, notice: "Signed out!", status: :see_other
  end
end

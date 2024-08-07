# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :logged_in?
  before_action :authenticate!

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def authenticate!
    return if high_voltage_page?
    redirect_to root_path unless logged_in?
  end

  private

  def high_voltage_page?
    params[:controller] == 'high_voltage/pages'
  end
end

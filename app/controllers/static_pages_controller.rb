# frozen_string_literal: true

# app/controllers/static_pages_controller.rb

# StaticPagesController handles the static pages of the application.
class StaticPagesController < ApplicationController
  skip_before_action :authenticate!, only: %i[index try]

  def index
    if current_user && session[:try_mode]
      session.delete(:try_mode)
    end
  end

  def try
    if session[:try_datetime] && Time.now - Time.parse(session[:try_datetime]) > 1.day
      session[:try_mode] = nil
    end

    if session[:try_mode].nil?
      @error_message = nil
      @code_review = CodeReview.code_review_by_code(try_params[:code])
      session[:try_mode] = true
      session[:try_datetime] = Time.now
    else
      @error_message = 'お試し回数は1人1回までです'
    end
  end

  private

  def try_params
    params.permit(:code)
  end
end

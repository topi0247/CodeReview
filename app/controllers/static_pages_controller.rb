# frozen_string_literal: true

# app/controllers/static_pages_controller.rb

# StaticPagesController handles the static pages of the application.
class StaticPagesController < ApplicationController
  skip_before_action :authenticate!, only: :index

  def index; end
end

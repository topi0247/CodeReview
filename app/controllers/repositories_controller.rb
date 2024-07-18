# frozen_string_literal: true

class RepositoriesController < ApplicationController
  def index
    @repositories = Github.new(session[:github_access_token]).get_repositories
  end

  def show
    @repository_name = params[:id]
    @files = Github.new(session[:github_access_token]).get_files(params[:id])
  end
end

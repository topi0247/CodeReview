class RepositoriesController < ApplicationController
  def index
    @repositories = Github.new(session[:github_access_token]).get_repositories
  end
end

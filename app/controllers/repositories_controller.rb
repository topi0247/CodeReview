# frozen_string_literal: true

class RepositoriesController < ApplicationController
  def index
    @repositories = Github.new(session[:github_access_token]).get_repositories
  end

  def show
    @repository_name = params[:id]
    @files = Github.new(session[:github_access_token]).get_files(params[:id])
    @content = nil
    @path = nil
    @languages = nil
  end

  def file
    repository_name = params[:id]
    @path = params[:path]
    @languages = set_language
    @content = Github.new(session[:github_access_token]).get_content(repository_name, @path)
  end

  private

  def set_language
    case @path.split('.').last
    when 'rb'
      'ruby'
    when 'js'
      'javascript'
    when 'html'
      'html'
    when 'erb'
      'erb'
    when 'slim'
      'slim'
    end
  end
end

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

  LANGS = {
    'rb' => 'ruby',
    'js' => 'javascript',
    'html' => 'html',
    'erb' => 'html',
    'slim' => 'html'
  }.freeze

  def set_language
    extention = @path.split('.').last
    LANGS[extention]
  end
end

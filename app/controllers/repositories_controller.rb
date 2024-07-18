# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :initialize_github

  def index
    @repositories = @git_hub.get_repositories
  end

  def show
    @repository_name = params[:id]
    @files = @git_hub.get_files(params[:id])
    @content = nil
    @path = nil
    @languages = nil
  end

  def file
    repository_name = params[:id]
    @path = params[:path]
    @languages = set_language
    @content = @git_hub.get_file_content(repository_name, @path)
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

  def initialize_github
    @git_hub = Github.new(current_user.name)
  end
end

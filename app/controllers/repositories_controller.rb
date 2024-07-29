# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :initialize_github
  before_action :set_repository_name, only: %i[show file code_review]

  def index
    @repositories = @git_hub.get_repositories
  end

  def show
    @files = @git_hub.get_files(params[:id])
    @content = nil
    @path = nil
    session[:commit_oid] = nil
    session[:file_path] = nil
    session[:code_review] = nil
  end

  def file
    session[:file_path] = nil
    session[:code_review] = nil
    @path = params[:path]
    file_content = @git_hub.get_file_content(@repository_name, @path)
    commit_oid = @git_hub.get_commit_oid(@repository_name, @path)
    session[:commit_oid] = commit_oid
    @commit_url = "https://github.com/#{current_user.name}/CodeReview/commit/#{commit_oid}"
    # マークダウン式でコードを表示
    # NOTE: #{@git_hub.get_file_content(@repository_name, @path)}の左にインデントがあると表示が崩れる
    @content = "```#{@path.split('.').last}
#{file_content}
"
    pre_review_contents = ReviewLog.find_by(repository_name: @repository_name).review_contents.find_by(file_path: @path)
    @code_review = nil
    if pre_review_contents.present?
      pre_commit_oid = pre_review_contents.commit_oid
      if pre_commit_oid == commit_oid
        @code_review = {
          good: pre_review_contents.content['good'],
          improve: pre_review_contents.content['improve']
        }
      end
    end
  end

  def code_review
    @code_review = CodeReview.code_review(current_user.name, params[:path], @repository_name)
    session[:file_path] = params[:path]
    session[:code_review] = @code_review
  end

  private

  def initialize_github
    @git_hub = Github.new(current_user.name)
  end

  def set_repository_name
    @repository_name = params[:id]
  end
end

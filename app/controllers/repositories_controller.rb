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
  end

  def file
    @path = params[:path]
    # マークダウン式でコードを表示
    # NOTE: #{@git_hub.get_file_content(@repository_name, @path)}の左にインデントがあると表示が崩れる
    @content = "```#{@path.split('.').last}
#{@git_hub.get_file_content(@repository_name, @path)}
"
  end

  def code_review
    @code_review = CodeReview.code_review(current_user.name, params[:path], @repository_name)
  end

  private

  def initialize_github
    @git_hub = Github.new(current_user.name)
  end

  def set_repository_name
    @repository_name = params[:id]
  end
end

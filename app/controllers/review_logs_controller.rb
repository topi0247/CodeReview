class ReviewLogsController < ApplicationController
  before_action :set_repository_name, only: %i[show create]

  def index
    @review_logs = current_user.review_logs
  end

  def show
    @review_log = current_user.review_logs.find_by(repository_name: @repository_name)
    if @review_log.nil?
      redirect_to review_logs_path, alert: 'Review log not found'
    end
  end

  def create
    file_path = session[:file_path]
    commit_oid = session[:commit_oid]
    content = session[:code_review]
    review_log = current_user.review_logs.find_or_create_by(repository_name: @repository_name)
    review_log.review_contents.build(file_path: file_path, commit_oid: commit_oid, content: content)
    if review_log.save
      redirect_to repository_path(@repository_name), notice: 'Review log created'
    else
      redirect_to repository_path(@repository_name), notice: 'Review log not created'
    end
  end

  private

  def set_repository_name
    @repository_name = params[:repository_id]
  end
end

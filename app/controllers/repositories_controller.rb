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
    @languages = nil
  end

  def file
    @path = params[:path]
    @languages = set_language
    @content = @git_hub.get_file_content(@repository_name, @path)
  end

  def code_review
    path = params[:path]
    content = @git_hub.get_file_content(@repository_name, path)
    begin
      @chatgpt = Chatgpt.call("あなたは企業の採用担当のエンジニアです。
                              要件のもと、以下の形式に従いコードレビューをしてください
                              # 要件
                              - Ruby on Rails7.1.3
                              - Ruby3.2.2
                              - エンジニア未経験がポートフォリオとして就職活動で使うものとする
                              - コメントは不要
                              - より高度なコードを書くことを求める

                              # 形式
                              - 修正案は出さないこと
                              - json形式で返却すること
                              - 下記形式に従うこと

                              'reviews': {
                                'good': [
                                  '良い点',
                                  '良い点',
                                ],
                                'improve': [
                                  '改善点',
                                  '改善点',
                                ]
                              }

                              # コード
                              ```
                              #{content}
                              ```
                              ")
    rescue Net::ReadTimeout
      @chatgpt = nil
    end
    @code_review = nil
    if @chatgpt.present?
      @chatgpt = @chatgpt.gsub(/```json\n|```/, '')
      begin
        json_data = JSON.parse(@chatgpt)
        @code_review = {
          good: json_data['reviews']['good'],
          improve: json_data['reviews']['improve']
        }
      rescue JSON::ParserError
        Rails.logger.error('ChatGPT response is not JSON format')
        @code_review = nil
      end
    end
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

  def set_repository_name
    @repository_name = params[:id]
  end
end

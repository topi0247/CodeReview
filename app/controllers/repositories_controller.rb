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
    # マークダウン式でコードを表示
    # NOTE: #{@git_hub.get_file_content(@repository_name, @path)}の左にインデントがあると表示が崩れる
    @content = "```#{@path.split('.').last}
#{@git_hub.get_file_content(@repository_name, @path)}
"
  end

  def code_review
    path = params[:path]
    content = @git_hub.get_file_content(@repository_name, path)
    gemfile = @git_hub.get_file_content(@repository_name, 'Gemfile')

    begin
      @chatgpt = Chatgpt.call("あなたは企業の採用担当のエンジニアです。
                              要件のもと、以下の形式に従いコードレビューをしてください
                              # 要件
                              - Ruby on Rails
                              - Ruby version
                              - Ruby on RailsとRubyのバージョンはGemfileから取得する
                              - 利用しているGemはGemfileから取得する
                              - Gemfileはコードレビューの対象にしない
                              - エンジニア未経験がポートフォリオとして就職活動で使うものとする
                              - コメントは不要
                              - より高度なコードを書くことを求める

                              # 形式
                              - 修正案は出さないこと
                              - json形式で返却すること
                              - 下記形式に従うこと
                              - 良い点と悪い点の数は行数に応じて変動する

                              # 良い点・悪い点の数
                              - コードが10行以下なら2点ずつ、ただしなければ「レビューはありません」とする
                              - コードが11～30行なら3点ずつ、ただしなければ「レビューはありません」とする
                              - コードが31～60行以上なら4点ずつ、ただしなければ「レビューはありません」とする
                              - コードが61行以上なら5点ずつ、ただしなければ「レビューはありません」とする

                              'reviews': {
                                'good': [
                                  '良い点',
                                ],
                                'improve': [
                                  '改善点',
                                ]
                              }

                              # コード
                              ```
                              #{content}
                              ```
                              ## Gemfile
                              ```
                              #{gemfile}
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

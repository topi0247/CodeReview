module CodeReview
  def self.code_review_by_code(code)
    get_code_review(code, true)
  end

  def self.code_review(name, path, repository_name)
    github = Github.new(name)
    content = github.get_file_content(repository_name, path)
    gemfile = github.get_file_content(repository_name, 'Gemfile')
    get_code_review(content, false, gemfile)
  end

  private

  def self.get_code_review(content, is_try = false, gemfile = nil)
    begin
      chatgpt = Chatgpt.call("あなたは企業の採用担当のエンジニアです。
                              要件のもと、以下の形式に従いコードレビューをしてください
                              # 要件
                              - Ruby on Rails
                              - Ruby version
                #{!is_try && "- Ruby on RailsとRubyのバージョンはGemfileから取得する
                              - 利用しているGemはGemfileから取得する
                              - Gemfileはコードレビューの対象にしない"}
                              - エンジニア未経験がポートフォリオとして就職活動で使うものとする
                              - コメントは不要
                              - より高度なコードを書くことを求める

                              # 形式
                              - 修正案は出さないこと
                              - json形式で返却すること
                              - 下記形式に従うこと
                              - 良い点と改善点の数は後述の通り

                              # 良い点・改善点の数
                  #{is_try ? "- 良い点・改善点は1点ずつ" :
                              "- コードが10行以下なら2点ずつ、ただしなければ「レビューはありません」とする
                              - コードが11～30行なら3点ずつ、ただしなければ「レビューはありません」とする
                              - コードが31～60行以上なら4点ずつ、ただしなければ「レビューはありません」とする
                              - コードが61行以上なら5点ずつ、ただしなければ「レビューはありません」とする" }

                              # 形式
                              reviews: {
                                good: ['良い点'],
                                improve: ['改善点']
                              }

                              # コード
                              ```
                              #{content}
                              ```
                  #{is_try && "## Gemfile
                              ```
                              #{gemfile}
                              ```"}
                              ")
    rescue Net::ReadTimeout
      chatgpt = nil
    end
    code_review = nil
    if chatgpt.present?
      chatgpt = chatgpt.gsub(/```json\n|```/, '')
      begin
        json_data = JSON.parse(chatgpt)
        code_review = {
          good: json_data['reviews']['good'],
          improve: json_data['reviews']['improve']
        }
      rescue JSON::ParserError
        Rails.logger.error('ChatGPT response is not JSON format')
        code_review = nil
      end
    end
    code_review
  end
end
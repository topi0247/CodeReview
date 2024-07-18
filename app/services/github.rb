# frozen_string_literal: true

class Github
  def initialize(access_token)
    @client = Octokit::Client.new(access_token:)
  end

  def get_repositories
    @client.repositories
  end

  def get_files(repository_name)
    current_user = @client.user
    repo_name = "#{current_user.login}/#{repository_name}"
    files = get_all_files_recursive(repo_name).flatten

    files.group_by { |file| File.dirname(file[:path]) }
  end

  private

  def get_all_files_recursive(repo_name, path = '')
    contents = @client.contents(repo_name, path: path)

    files = []

    check_files = %w[.rb .js .html .erb .slim]
    check_dir = %w[controllers models views services helpers javascript]

    contents.each do |content|
      if content.type == 'file' && check_dir.any? { |dir| content.path.include?(dir) } && check_files.include?(File.extname(content.path))
      file_contents = @client.contents(repo_name, path: content.path)
      files << { path: content.path }
      elsif content.type == 'dir'
      files << get_all_files_recursive(repo_name, content.path)
      end
    end

    files
  end
end

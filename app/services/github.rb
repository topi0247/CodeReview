# frozen_string_literal: true

class Github
  def initialize(access_token)
    @client = Octokit::Client.new(access_token:)
  end

  def get_repositories
    @client.repositories
  end

  def get_files(repository_name)
    set_repo_name(repository_name)
    files = get_all_files_recursive.flatten

    files.group_by { |file| File.dirname(file[:path]) }
  end

  def get_content(repository_name, path)
    set_repo_name(repository_name)
    content = @client.contents(@repo_name, path: path)
    Base64.decode64(content.content)
  end

  private

  def get_all_files_recursive(path = '')
    contents = @client.contents(@repo_name, path: path)

    files = []

    check_files = %w[.rb .js .html .erb .slim]
    check_dir = %w[controllers models views services helpers javascript]

    contents.each do |content|
      if content.type == 'file' && check_dir.any? { |dir| content.path.include?(dir) } && check_files.include?(File.extname(content.path))
      files << { path: content.path }
      elsif content.type == 'dir'
      files << get_all_files_recursive(content.path)
      end
    end

    files
  end

  def set_repo_name(repository_name)
    current_user = @client.user
    @repo_name = "#{current_user.login}/#{repository_name}"
  end
end

class Github
  def initialize(access_token)
    @client = Octokit::Client.new(access_token: access_token)
  end

  def get_repositories
    @client.repositories
  end
end

# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'
require 'concurrent'

class Github
  AUTH_HEADER = "Bearer #{ENV['GITHUB_ACCESS_TOKEN']}"
  HTTP = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
    def headers(_context)
      { 'Authorization': AUTH_HEADER }
    end
  end

  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  REPOSITORIES_QUERY = Client.parse <<~GRAPHQL
    query($user_name: String!) {
      user(login: $user_name) {
        repositories(last: 21, privacy: PUBLIC) {
          nodes {
            name
          }
        }
      }
    }
  GRAPHQL

  FILE_CONTENT_QUERY = Client.parse <<~GRAPHQL
    query($owner: String!, $name: String!, $expression: String!, $qualifiedName: String!, $file_path: String!) {
      repository(owner: $owner, name: $name) {
        object(expression: $expression) {
          ... on Blob {
            text
          }
        }
        ref(qualifiedName: $qualifiedName) {
          target {
            ... on Commit {
              history(first: 1, path: $file_path) {
                edges {
                  node {
                    oid
                  }
                }
              }
            }
          }
        }
      }
    }
  GRAPHQL

  FILES_QUERY = Client.parse <<~GRAPHQL
    query($owner: String!, $name: String!, $expression: String!) {
      repository(owner: $owner, name: $name) {
        object(expression: $expression) {
          ... on Tree {
            entries {
              name
              type
            }
          }
        }
      }
    }
  GRAPHQL

  DEFAULT_BRANCH_QUERY = Client.parse <<~GRAPHQL
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        defaultBranchRef {
          name
        }
      }
    }
  GRAPHQL

  def initialize(user_name)
    @user_name = user_name
  end

  def get_repositories
    result = Client.query(REPOSITORIES_QUERY, variables: { user_name: @user_name })
    if result.data && result.data.user
      result.data.user.repositories.nodes.map { |repo| repo.name }
    else
      handle_errors(result)
    end
  end

  def get_files(repository_name)
    all_files = Concurrent::Array.new
    directories = ['controllers', 'models', 'views', 'services', 'mailers']
    tasks = directories.map do |subdir|
      Concurrent::Promise.execute do
        begin
          files = fetch_files(repository_name, "app/#{subdir}/")
          all_files.concat(files)
        rescue => e
          Rails.logger.error "Error fetching files in app/#{subdir}/: #{e.message}"
        end
      end
    end

    Concurrent::Promise.zip(*tasks).value!
    all_files << "config/routes.rb"
    all_files << "db/schema.rb"
    all_files.sort.group_by { |file| File.dirname(file) }
  end

  def get_file_content(repository_name, file_path)
    default_branch = Client.query(DEFAULT_BRANCH_QUERY, variables: { owner: @user_name, name: repository_name })
    if default_branch.errors.any?
      handle_errors(default_branch)
    end

    branch_name = default_branch.data.repository.default_branch_ref.name
    if branch_name.nil?
      raise "No default branch found for repository #{repository_name}"
    end

    result = Client.query(FILE_CONTENT_QUERY, variables: { owner: @user_name, name: repository_name, expression: "#{branch_name}:#{file_path}", qualifiedName: "refs/heads/#{branch_name}", file_path: file_path })

    if result.data && result.data.repository && result.data.repository.object && result.data.repository.ref
      commit_oid = result.data.repository.ref.target.history.edges.first.node.oid
      commit_url = "https://github.com/#{@user_name}/#{repository_name}/commit/#{commit_oid}"
      { content: result.data.repository.object.text, commit_url: commit_url }
    else
      handle_errors(result)
    end
  end

  private

  def handle_errors(result)
    if result.errors.any?
      raise "GraphQL errors: #{result.errors.map(&:message).join(', ')}"
    else
      raise "Unknown error: #{result.to_h.inspect}"
    end
  end

  def fetch_files(repository_name, path = "")
    result = Client.query(FILES_QUERY, variables: { owner: @user_name, name: repository_name, expression: "HEAD:#{path}" })

    if result.errors.any?
      Rails.logger.error "GraphQL errors: #{result.errors.map(&:message).join(', ')}"
      return []
    end

    unless result.data && result.data.repository && result.data.repository.object
      Rails.logger.error "No data found for path: #{path}"
      return []
    end

    entries = result.data.repository.object.entries
    full_paths = Concurrent::Array.new

    tasks = entries.map do |entry|
      Concurrent::Promise.execute do
        full_path = "#{path}#{entry.name}"
        if entry.type == 'blob' && ['.rb', '.erb', '.html', '.slim'].include?(File.extname(entry.name))
          full_paths << full_path
        elsif entry.type == 'tree'
          full_paths.concat(fetch_files(repository_name, "#{full_path}/"))
        end
      end
    end

    Concurrent::Promise.zip(*tasks).value!

    full_paths
  end
end

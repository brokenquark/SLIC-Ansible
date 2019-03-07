require 'sidekiq'
require 'net/http'
require 'octokit'

class SourceRepoWorker
  private

  def source_repo(cookbook_json)
    url = source_repo_url(cookbook_json)

    url.match(%r{(?<=github.com\/)[\w-]+\/[\w-]+}).to_s
  end

  def source_repo_url(cookbook_json)
    JSON.parse(cookbook_json).fetch('source_url', '') || ''
  end

  def octokit_client
    Octokit::Client.new(
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    )
  end
end

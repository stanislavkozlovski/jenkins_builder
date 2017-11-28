require 'jenkins_api_client'

class JenkinsClient
  attr_reader :client

  def initialize(server_url:, username:, password:, builds:)
    @client = JenkinsApi::Client.new(:server_url => server_url,
                                     :username => username, :password => password)
    # Initialize builds
    @builds_by_name = builds.inject({}) do |hash, build|
      hash[build.name] = build
      hash
    end
    puts @builds_by_name
  end
end

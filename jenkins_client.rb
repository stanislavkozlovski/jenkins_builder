require 'jenkins_api_client'

class JenkinsClient
  attr_reader :client

  def initialize(server_url:, username:, password:)
    @client = JenkinsApi::Client.new(:server_url => server_url,
                                     :username => username, :password => password)
  end
end

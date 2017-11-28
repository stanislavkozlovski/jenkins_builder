require 'jenkins_api_client'

class JenkinsClient
  attr_reader :client

  def initialize(credentials:, builds:)
    @credentials = credentials
    @client = JenkinsApi::Client.new(server_url: credentials.server_url,
                                     username:   credentials.username,
                                     password:   credentials.api_token || credentials.password)
    # Initialize builds
    @builds_by_name = builds.inject({}) do |hash, build|
      hash[build.slang_name] = build
      hash
    end
  end

  def build_job(job_name)
    # validate the name
    job = @builds_by_name[job_name]
    actual_job_name = @client.job.list(job.jenkins_name).first
    if actual_job_name != job.jenkins_name
      raise Exception, "Queried job #{job_name} is not #{actual_job_name}"
    end
    
    puts @client.job.build(@builds_by_name[job_name].jenkins_name, BUILD_BRANCH: 'develop', ENVIRONMENT: 'alpha')
    puts @client.job.get_current_build_number(@builds_by_name[job_name].jenkins_name)
  end
end

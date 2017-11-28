require 'jenkins_api_client'
require_relative 'jenkins_build'

class JenkinsClient
  attr_reader :client

  def initialize(credentials:, builds:, logger:)
    @credentials = credentials
    @client = JenkinsApi::Client.new(server_url: credentials.server_url,
                                     username:   credentials.username,
                                     password:   credentials.api_token || credentials.password)
    @logger = logger

    # Initialize builds
    @builds_by_name = builds.inject({}) do |hash, build|
      hash[build.slang_name] = build
      hash
    end
    @currently_building = []
    @lock = Mutex.new

    @logger.info("Initialized jobs #{@builds_by_name.keys.join(', ')}")
  end

  def build_job(job_name)
    # validate the name
    job = @builds_by_name[job_name]
    actual_job_name = @client.job.list(job.jenkins_name).first
    if actual_job_name != job.jenkins_name
      @logger.error("Tried to find a job named #{job.jenkins_name}, but found #{actual_job_name} (#{actual_job_name.class})!")
      raise Exception, "Queried job #{job_name} is not #{actual_job_name}"
    end

    build_number = @client.job.get_current_build_number(job.jenkins_name) + 1
    @logger.info("[#{Time.now}] Starting build ##{build_number} for #{actual_job_name}")
    @client.job.build(job.jenkins_name, **job.parameters)
    build = JenkinsBuild.new(job, build_number)

    @lock.synchronize do
      @currently_building << job
    end

    initiate_job_status_polling(build)
  end

  def initiate_job_status_polling(build)
    Thread.new do
      while true
        current_status = @client.job.get_current_build_status(build.jenkins_name)
        if current_status != 'running'
          @logger.info("Job ##{build.build_number} of #{build.slang_name} has ended with status #{current_status.upcase}")
          break
        end
        sleep 1
      end
      @lock.synchronize do
        @currently_building.delete_if { |building_job| building_job == job}
      end
    end
  end
end

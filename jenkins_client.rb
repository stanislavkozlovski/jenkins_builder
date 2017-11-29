require 'jenkins_api_client'
require_relative 'jenkins_build'

class JenkinsClient
  attr_reader :client

  class InexistentJobException < StandardError; end

  class JobFailureException < StandardError; end

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
    @failed_builds = []
    @lock = Mutex.new

    @logger.info("Initialized jobs #{@builds_by_name.keys.join(', ')}")
  end

  #
  # Builds multiple jobs asynchronously
  #
  def build_jobs(job_names)
    @failed_builds = []  # reset
    jobs = job_names.map {|job| validate_job!(job)}

    threads = jobs.map do |job|
      build_number = @client.job.get_current_build_number(job.jenkins_name) + 1
      @logger.info("[#{Time.now}] Starting build ##{build_number} for #{job.jenkins_name}")
      @client.job.build(job.jenkins_name, **job.parameters)
      build = JenkinsBuild.new(job, build_number)


      Thread.new do
        is_successful = initiate_job_status_polling(build)
        unless is_successful
          @lock.synchronize do
            @failed_builds << build
          end
        end
      end
    end

    threads.each(&:join)

    unless @failed_builds.empty?
      error_message = @failed_builds.inject('') do |msg, build|
        msg += "Build ##{build.build_number} for #{build.jenkins_name} has failed with status #{build.final_status}\n"
      end
      raise JobFailureException, error_message.strip
    end
  end

  def build_job(job_name)
    # validate the name
    job = validate_job!(job_name)

    build_number = @client.job.get_current_build_number(job.jenkins_name) + 1
    @logger.info("[#{Time.now}] Starting build ##{build_number} for #{job.jenkins_name}")
    @client.job.build(job.jenkins_name, **job.parameters)
    build = JenkinsBuild.new(job, build_number)

    is_successful = initiate_job_status_polling(build)
    raise JobFailureException, "Build ##{build_number} for #{job.jenkins_name} has failed with status #{build.final_status}" unless is_successful
  end

  #
  # Given a slang name for a job, validates that it exists in JIRA
  #   if it doesn't, it raises an InexistentJobException
  #
  def validate_job!(job_name)
    job = @builds_by_name[job_name]
    raise InexistentJobException, "Queried job #{job_name} is does not exist" if job.nil?

    actual_job_name = @client.job.list(job.jenkins_name).first
    if actual_job_name != job.jenkins_name
      @logger.error("Tried to find a job named #{job.jenkins_name}, but found #{actual_job_name} (#{actual_job_name.class})!")
      raise InexistentJobException, "Queried job #{job_name} is not #{actual_job_name}"
    end

    job
  end

  #
  # Starts polling the job, tracking if it has completed successfully
  # @return - true or false, depending if the job succeeded
  #
  def initiate_job_status_polling(build)
    while true
      current_status = @client.job.get_current_build_status(build.jenkins_name).upcase
      if current_status != JenkinsBuild::RUNNING_STATUS
        @logger.info("Job ##{build.build_number} of #{build.slang_name} has ended with status #{current_status}")
        build.final_status = current_status
        break
      end
      sleep 1
    end

    build.final_status == JenkinsBuild::SUCCESSFUL_STATUS
  end
end

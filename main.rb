require 'dotenv'
require 'yaml'
require_relative './jenkins_client'
require_relative './jira_client'
require_relative './logger'
require_relative './config_parser'

Dotenv.load



if ARGV[0].nil?
  JenkinsLogger.error('You must add a job name as  the first argument')
  abort
end
job_name = ARGV[0]

j_credentials = ConfigParser.parse_jenkins_credentials
j_client = JenkinsClient.new(credentials: j_credentials,
                             builds:     ConfigParser.parse_builds,
                             logger: JenkinsLogger)


begin
  j_client.build_job(job_name)
  # ggl_us, ggl_pw = ConfigParser.parse_google_credentials
  # JiraClient.new(ggl_us, ggl_pw)
rescue JenkinsClient::InexistentJobException
  JenkinsLogger.error("Job #{job_name} does not exist!")
  abort
rescue JenkinsClient::JobFailureException => e
  JenkinsLogger.error("Job #{job_name} failed! #{e.message}")
  abort
end

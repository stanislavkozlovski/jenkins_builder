require 'dotenv'
require 'optparse'
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

options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = 'Usage: builder.rb [options] application_name'

  opts.on( '-j', '--jira_ticket TICKET_TAG', 'Add a comment to a jira ticket' ) do |tag|
    options[:jira_ticket_tag] = tag
  end
end

optparse.parse!
job_name = ARGV[0]

j_credentials = ConfigParser.parse_jenkins_credentials
j_client = JenkinsClient.new(credentials: j_credentials,
                             builds:     ConfigParser.parse_builds,
                             logger: JenkinsLogger)


begin
  j_client.build_job(job_name)
  if options[:jira_ticket_tag]
    begin
      ggl_us, ggl_pw = ConfigParser.parse_google_credentials
      jira_client = JiraClient.new(ggl_us, ggl_pw).start
      jira_client.comment(options[:jira_ticket_tag], 'Hello')
    rescue JiraClient::NonExistentTicketError => e
      JenkinsLogger.warn(e.message)
    end

  end

rescue JenkinsClient::InexistentJobException
  JenkinsLogger.error("Job #{job_name} does not exist!")
  abort
rescue JenkinsClient::JobFailureException => e
  JenkinsLogger.error("Job #{job_name} failed! #{e.message}")
  abort
end

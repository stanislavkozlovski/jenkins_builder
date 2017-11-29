require 'dotenv'
require 'optparse'
require 'yaml'
require_relative './jenkins_client'
require_relative './jira_client'
require_relative './logger'
require_relative './config_parser'

if ARGV[0].nil?
  JenkinsLogger.error('You must add a job name as  the first argument')
  abort
end

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = 'Usage: builder.rb [options] application_name'

  opts.on('-j', '--jira_ticket TICKET_TAG', 'Add a comment to a jira ticket' ) do |tag|
    options[:jira_ticket_tag] = tag
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end
optparse.parse!
job_names = ARGV.clone

j_credentials = ConfigParser.parse_jenkins_credentials
j_client = JenkinsClient.new(credentials: j_credentials,
                             builds:      ConfigParser.parse_builds,
                             logger:      JenkinsLogger)

# Validate that the jobs exist and do not run build if one does not exist
job_names.each do |job_name|
  begin
    j_client.validate_job!(job_name)
  rescue JenkinsClient::InexistentJobException
    JenkinsLogger.error("Job #{job_name} does not exist!")
    abort
  end
end

# Build the job/jobs
begin
  if job_names.length > 1
    j_client.build_jobs(job_names)
  else
    j_client.build_job(job_names.first)
  end
rescue JenkinsClient::JobFailureException => e
  JenkinsLogger.error(e.message)
  abort
end

# Add a JIRA comment if everything was successful
if options[:jira_ticket_tag]
  begin
    ggl_us, ggl_pw = ConfigParser.parse_google_credentials
    jira_client = JiraClient.new(ggl_us, ggl_pw,
                                 ConfigParser.parse_jira_options).start
    jira_client.comment(options[:jira_ticket_tag])
  rescue JiraClient::NonExistentTicketError => e
    JenkinsLogger.warn(e.message)
  end
end

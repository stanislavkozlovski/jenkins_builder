require 'dotenv'
require 'optparse'
require 'yaml'
require_relative './jenkins_client'
require_relative './jira_client'
require_relative './logger'
require_relative './config_parser'
require_relative './notifier'

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

  opts.on('-e', '--environment ENVIRONMENT', 'Explicitly choose the environment' ) do |env|
    options[:env] = env
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end
optparse.parse!
job_names = ARGV.clone
if job_names.empty?
  JenkinsLogger.error('You must add a job name as  the first argument')
  abort
end

j_credentials = ConfigParser.parse_jenkins_credentials
j_client = JenkinsClient.new(credentials: j_credentials,
                             builds:      ConfigParser.parse_builds,
                             logger:      JenkinsLogger)

# Validate that the jobs exist and do not run build if one does not exist
job_names.each_with_index do |job_name, idx|
  begin
    j_client.validate_job!(job_name, options[:env])
  rescue JenkinsClient::InexistentJobException
    similar_job_name = j_client.fuzzy_match_job_name(job_name)

    if similar_job_name.nil?
      JenkinsLogger.error("Job #{job_name} does not exist!")
      abort
    end

    puts "#{job_name} does not exist. Did you mean #{similar_job_name.bold} (y/n)?"
    choice = STDIN.gets.chomp
    unless %w[y Y yes ye yeah ya ys].include?(choice)
      JenkinsLogger.error('Could not find the desired job. Aborting...')
      abort
    end

    job_names[idx] = similar_job_name
  end
end

# Build the job/jobs
begin
  if job_names.length > 1
    j_client.build_jobs(job_names)
    Notifier.notify("#{job_names.join(',')} have built successfully!")
  else
    j_client.build_job(job_names.first, options[:env])
    Notifier.notify("#{job_names.first} has built successfully!")
  end
rescue JenkinsClient::JobFailureException => e
  JenkinsLogger.error(e.message)
  Notifier.notify(e.message)
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

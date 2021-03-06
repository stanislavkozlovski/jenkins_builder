require 'dotenv'
require_relative './jenkins_job'
require_relative './jenkins_credentials'
require_relative './jira_options'

# Functions for translating configurable values into domain types
module ConfigParser
  module_function

  @parsed_options = YAML.load_file('options.yml')

  #
  # Parses the options.yml file and returns a list of JenkinsBuild objects
  # @return [Array<JenkinsJob>]
  #
  def parse_builds
    builds = @parsed_options['builds']
    env_parameter = builds['jenkins_meta_options']['environment_parameter']
    branch_parameter = builds['jenkins_meta_options']['branch_parameter']

    builds.inject([]) do |list, (build_name, settings)|
      next list if build_name == 'jenkins_meta_options'

      default_meta_environment = settings['default_env']
      settings.each do |build_env_name, build_settings|
        next if build_env_name == 'default_env'
        next unless build_settings
        # puts build_settings.inspect
        list << JenkinsJob.new(build_name, build_settings['name'],
                               env_parameter, branch_parameter, default_meta_environment,
                               build_settings['default_env'] || build_env_name, build_settings['default_branch'])
      end

      list
    end
  end

  def parse_jira_options
    jira_options = @parsed_options['jira']
    JiraOptions.new(jira_options['base_url'], jira_options['default_comment'])
  end

  #
  # Parses the Jenkins credentials from the .env file
  #
  def parse_jenkins_credentials
    Dotenv.load

    JenkinsCredentials.new(username: ENV['JENKINS_USERNAME'],
                           api_token: ENV['JENKINS_API_TOKEN'],
                           server_url: ENV['JENKINS_URL'])
  end

  def parse_google_credentials
    Dotenv.load

    [ENV['GOOGLE_USERNAME'], ENV['GOOGLE_PASSWORD']]
  end
end

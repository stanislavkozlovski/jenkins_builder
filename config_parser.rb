require 'dotenv'
require_relative './jenkins_job'
require_relative './jenkins_credentials'

# Functions for translating configurable values into domain types
module ConfigParser
  module_function

  #
  # Parses the builds.yml file and returns a list of JenkinsBuild objects
  #
  def parse_builds
    builds = YAML.load_file('builds.yml')
    builds.inject([]) do |list, (build_name, settings)|
      list << JenkinsJob.new(build_name, settings['name'],
                             settings['default_env'], settings['default_branch'])
      list
    end
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

# Functions for translating config values into domain types
require_relative './jenkins_build'

module ConfigParser
  module_function

  #
  # Parses the builds.yml file and returns a list of JenkinsBuild objects
  #
  def parse_builds
    builds = YAML.load_file('builds.yml')
    builds.inject([]) do |list, (build_name, settings)|
      list << JenkinsBuild.new(build_name, settings[:default_env], settings[:default_branch])
      list
    end
  end
end

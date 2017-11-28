require 'dotenv'
require 'yaml'
require_relative './jenkins_client'
require_relative './logger'
require_relative './config_parser'
Dotenv.load

j_credentials = ConfigParser.parse_credentials
j_client = JenkinsClient.new(credentials: j_credentials,
                             builds:     ConfigParser.parse_builds,
                             logger: JenkinsLogger)
j_client.build_job 'soap'

while true

end
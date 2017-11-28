require 'dotenv'
require 'yaml'
require_relative './jenkins_client'
require_relative './config_parser'
Dotenv.load

j_client = JenkinsClient.new(server_url: ENV['JENKINS_URL'],
                             username:   ENV['JENKINS_USERNAME'],
                             password:   ENV['JENKINS_API_TOKEN'],
                             builds:     ConfigParser.parse_builds)

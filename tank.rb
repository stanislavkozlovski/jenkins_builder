require 'dotenv'
require_relative './jenkins_client'

Dotenv.load

j_client = JenkinsClient.new(server_url: ENV['JENKINS_URL'],
                             username: ENV['JENKINS_USERNAME'],
                             password: ENV['JENKINS_API_TOKEN'])



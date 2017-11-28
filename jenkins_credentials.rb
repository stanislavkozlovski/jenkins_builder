# A credentials domain type object for Jenkins

class JenkinsCredentials
  attr_reader :username, :password, :server_url, :server_ip, :api_token

  def initialize(username: nil, password: nil, api_token: nil, server_url: nil, server_ip: nil)
    @username = username
    @password = password
    @server_url = server_url
    @server_ip = server_ip
    @api_token = api_token
  end
end

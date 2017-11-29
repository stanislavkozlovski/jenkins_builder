# A representation of a single Job with custom configuration (e.g environment)
class JenkinsJob
  attr_reader :slang_name, :jenkins_name, :parameters

  def initialize(slang_name, jenkins_name, env_parameter, branch_parameter, default_env = nil, default_branch = nil)
    @slang_name = slang_name
    @jenkins_name = jenkins_name
    @default_env = default_env
    @default_branch = default_branch
    @selected_env = default_env
    @selected_branch = default_branch

    @current_env = default_env
    @current_branch = default_branch

    @branch_parameter = branch_parameter.to_sym
    @env_parameter = env_parameter.to_sym
    @parameters = {@branch_parameter => @selected_branch,
                   @env_parameter => @selected_env}
  end

  def add_env(env)
    @selected_env = env
    @parameters[@env_parameter] = @selected_env
  end

  def add_branch(branch)
    @selected_branch = branch
    @parameters[@branch_parameter] = @selected_branch
  end

  def ==(job)
    @jenkins_name == job.jenkins_name && @parameters == job.parameters
  end
end

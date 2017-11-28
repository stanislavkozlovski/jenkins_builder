class JenkinsJob
  attr_reader :slang_name, :jenkins_name, :parameters

  def initialize(slang_name, jenkins_name, default_env = nil, default_branch = nil)
    @slang_name = slang_name
    @jenkins_name = jenkins_name
    @default_env = default_env
    @default_branch = default_branch
    @selected_env = default_env
    @selected_branch = default_branch

    @current_env = default_env
    @current_branch = default_branch

    @parameters = {BUILD_BRANCH: @selected_branch, ENVIRONMENT: @selected_env}
  end

  def add_env(env)
    @selected_env = env
    @parameters[:ENVIRONMENT] = @selected_env
  end

  def add_branch(branch)
    @selected_branch = branch
    @parameters[:BUILD_BRANCH] = @selected_branch
  end
end

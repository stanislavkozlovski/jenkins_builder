class JenkinsBuild
  attr_reader :name

  def initialize(name, default_env=nil, default_branch=nil)
    @name = name
    @default_env = default_env
    @default_branch = default_branch
    @selected_env = default_env
    @selected_branch = default_branch

    @current_env = default_env
    @current_branch = default_branch
  end

  def add_env(env)
    @selected_env = env
  end

  def add_branch(branch)
    @selected_branch = branch
  end
end

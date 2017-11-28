# Represents a specific build of a job

class JenkinsBuild
  attr_reader :job, :build_number

  def initialize(job, build_number)
    @job = job
    @build_number = build_number
  end

  def slang_name
    @job.slang_name
  end

  def jenkins_name
    @job.jenkins_name
  end

  def ==(build)
    @job == build.job && @build_number == build.build_number
  end
end

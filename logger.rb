require 'colorize'

module JenkinsLogger
  module_function

  def info(msg)
    puts "[INFO][#{fetch_timestamp}] #{msg}"
  end

  def debug(msg)
    puts "[DEBUG][#{fetch_timestamp}] #{msg}"
  end

  def warn(msg)
    puts "[WARNING][#{fetch_timestamp}] #{msg}".light_red
  end

  def error(msg)
    puts "[ERROR][#{fetch_timestamp}]\n#{msg}\n[ERROR][#{fetch_timestamp}]".red
  end

  def fetch_timestamp
    Time.now.strftime('%H:%M:%S.%3N')
  end
end

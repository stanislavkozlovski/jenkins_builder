class JiraOptions
  attr_reader :base_url, :default_comment

  def initialize(base_url, default_comment=nil)
    @base_url = base_url
    @default_comment = default_comment
  end
end

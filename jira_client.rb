require 'selenium-webdriver'
require_relative './selenium_client_mixins'

class JiraClient
  include SeleniumClient::GoogleMixin

  TICKET_PAGE_MAX_WAIT_TIME = 10  # in seconds

  class NonExistentTicketError < StandardError; end

  def initialize(username, password, options)
    @username = username
    @password = password
    @options = options
  end

  def wait_for(wait_time, &block)
    start_time = Time.now
    while true
      begin
        return block.call
      rescue Selenium::WebDriver::Error::WebDriverError
        # Retry until the given time passes
        raise if (Time.now - start_time) > wait_time
      end
    end
  end

  def start
    chrome_profile = Selenium::WebDriver::Chrome::Profile.new
    @driver = Selenium::WebDriver.for(:chrome, profile: chrome_profile)

    authenticate
    self
  end

  def authenticate
    @driver.navigate.to(@options.base_url)

    sign_in(navigate_to_page: false)
  end

  def comment(ticket_tag, comment=nil)
    open_ticket_page(build_ticket_url(ticket_tag), ticket_tag)

    comment = comment || @options.default_comment

    element = wait_for(TICKET_PAGE_MAX_WAIT_TIME) do
       @driver.find_element(id: 'footer-comment-button')
    end
    element.click

    element = wait_for(1) do
      @driver.find_element(id: 'comment')
    end
    element.send_keys(comment)

    element = wait_for(1) do
      @driver.find_element(id: 'issue-comment-add-submit')
    end
    element.click

    wait_for(2) do
      @driver.quit
    end
  end

  #
  # Opens a JIRA ticket page
  #   retries a couple of times and tries to validate that the exact ticket is opened
  #
  def open_ticket_page(ticket_url, ticket_tag)
    retries = 0
    while @driver.current_url != ticket_url
      if retries > 3
        raise NonExistentTicketError, "Could not find Jira ticket #{ticket_tag}"
      end
      sleep 1
      @driver.navigate.to(ticket_url)
      retries += 1
    end

    # TODO: Validate we are on the exact ticket
    # TODO:   e.g ZOE-962r34 works, a it gets ZOE-962
    begin
      @driver.find_element(class: 'issue-error')
      raise NonExistentTicketError, "Could not find Jira ticket #{ticket_tag}"
    rescue Selenium::WebDriver::Error::NoSuchElementError
      # ignored
    end
  end

  def build_ticket_url(ticket_tag)
    "#{@options.base_url}/browse/#{ticket_tag}"
  end
end

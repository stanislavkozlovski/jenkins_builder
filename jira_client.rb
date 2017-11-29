require 'selenium-webdriver'
require_relative './selenium_client_mixins'

class JiraClient
  include SeleniumClient::GoogleMixin

  class NonExistentTicketError < StandardError; end

  def initialize(username, password, options)
    @username = username
    @password = password
    @options = options
  end

  def start
    chrome_profile = Selenium::WebDriver::Chrome::Profile.new
    chrome_profile.add_extension('/Users/stanislavkozlovski/Downloads/extension_1_14_18.crx')
    @driver = Selenium::WebDriver.for(:chrome, profile: chrome_profile)

    authenticate
    self
  end

  def authenticate
    @driver.navigate.to(@options.base_url)

    sign_in(navigate_to_page: false)
  end

  def comment(ticket_tag, comment)
    retries = 0
    while @driver.current_url !=  "#{@options.base_url}/browse/#{ticket_tag}"
      if retries > 3
        raise NonExistentTicketError, "Could not find Jira ticket #{ticket_tag}"
      end
      sleep 1
      @driver.navigate.to "#{@options.base_url}/browse/#{ticket_tag}"
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

    sleep 8
    element = @driver.find_element(id: 'footer-comment-button')
    element.click
    sleep 1
    element = @driver.find_element(id: 'comment')
    element.send_keys(comment)
    sleep 2

    element = @driver.find_element(id: 'issue-comment-add-submit')
    element.click
    sleep 2

    @driver.quit
  end
end
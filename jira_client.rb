require 'selenium-webdriver'

class JiraClient

  class NonExistentTicketError < StandardError; end

  def initialize(username, password)
    @username = username
    @password = password
  end

  def start
    chrome_profile = Selenium::WebDriver::Chrome::Profile.new()
    chrome_profile.add_extension('/Users/stanislavkozlovski/Downloads/extension_1_14_18.crx')
    @driver = Selenium::WebDriver.for(:chrome, profile: chrome_profile)

    authenticate
    self
  end

  def authenticate
    @driver.navigate.to 'https://sumupteam.atlassian.net/'

    element = @driver.find_element(id: 'google-signin-button')

    element.click

    element = @driver.find_element(id: 'identifierId')
    element.send_key(@username)

    element = @driver.find_element(id: 'identifierNext')
    element.click


    sleep 1
    element = @driver.find_element(xpath: "//div[@id='password']//input[@type='password']")
    element.send_key(@password)

    element = @driver.find_element(id: 'passwordNext')
    element.click
  end

  def comment(ticket_tag, comment)
    retries = 0
    while @driver.current_url !=  "https://sumupteam.atlassian.net/browse/#{ticket_tag}"
      if retries > 3
        raise NonExistentTicketError, "Could not find Jira ticket #{ticket_tag}"
      end
      sleep 1
      @driver.navigate.to "https://sumupteam.atlassian.net/browse/#{ticket_tag}"
      retries += 1
    end

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
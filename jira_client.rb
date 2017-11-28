require 'selenium-webdriver'

class JiraClient
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
    @driver.navigate.to 'https://sumupteam.atlassian.net/browse/SRP-238'

    element = @driver.find_element(id: 'google-signin-button')

    element.click

    element = @driver.find_element(id: 'identifierId')
    element.send_key(ggl_us)

    element = @driver.find_element(id: 'identifierNext')
    element.click


    sleep 1
    element = @driver.find_element(xpath: "//div[@id='password']//input[@type='password']")
    element.send_key(ggl_pw)

    element = @driver.find_element(id: 'passwordNext')
    element.click
  end

  def comment(ticket_tag, comment)
    driver.navigate.to "https://sumupteam.atlassian.net/browse/#{ticket_tag}"
    sleep 8
    element = @driver.find_element(id: 'footer-comment-button')
    element.click
    sleep 1
    element = @driver.find_element(id: 'comment')
    element.send_keys(comment)
    sleep 2

    # element = @driver.find_element(id: 'issue-comment-add-submit')
    # element.click

    @driver.quit
  end
end
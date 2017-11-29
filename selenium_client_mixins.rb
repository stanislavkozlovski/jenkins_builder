#
# Various mixins providing functionality for specific sites through a selenium driver
#

module SeleniumClient

  #
  # Provides an API for a selenium driver to navigate google pages
  #
  module GoogleMixin
    SIGN_IN_URL = 'https://accounts.google.com/signin/v2/identifier'

    #
    # Signs into google
    #
    def sign_in(username=nil, password=nil, navigate_to_page: true)
      @driver.navigate.to(SIGN_IN_URL) if navigate_to_page

      username = username || @username
      password = password || @password

      element = @driver.find_element(id: 'google-signin-button')
      element.click

      element = @driver.find_element(id: 'identifierId')
      element.send_key(username)

      element = @driver.find_element(id: 'identifierNext')
      element.click

      sleep 1
      element = @driver.find_element(xpath: "//div[@id='password']//input[@type='password']")
      element.send_key(password)

      element = @driver.find_element(id: 'passwordNext')
      element.click
    end
  end
end

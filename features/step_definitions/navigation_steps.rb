# WD
Given /^I am up top$/ do
  kaikifs.switch_to.default_content
end

# WD
Given /^I am on the "([^"]*)" tab$/ do |tab|
  kaikifs.switch_to.default_content
  kaikifs.find_element(:link_text, tab.titleize).click  # 'main_menu' #=> 'Main Menu'
end

# WD
When /^I open my Action List$/i do
  kaikifs.click_and_wait(:xpath, "//a[@class='portal_link' and @title='Action List']")
  kaikifs.select_frame "iframeportlet"
end

# WD
When /^I open my Action List to the last page$/i do
  kaikifs.click_and_wait(:xpath, "//a[@class='portal_link' and @title='Action List']")
  kaikifs.select_frame "iframeportlet"
  begin
    last_link = kaikifs.find_element(:link_text, 'Last')
    last_link.click
  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
  end
end

# WD
When /^I open my Action List, refreshing until that document appears$/i do
  steps %{
    When I open my Action List
    And  I wait for that document to appear in my Action List
  }
end

# WD
When /^I wait for that document to appear in my Action List$/i do
  doc_nbr = kaikifs.record[:document_number]
  refresh_tries = 5
  wait_time = 6

  begin
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { kaikifs.find_element(:xpath, "//a[contains(text(), '#{doc_nbr}')]") }
    kaikifs.find_element(:xpath, "//a[contains(text(), '#{doc_nbr}')]").text
  rescue Selenium::WebDriver::Error::NoSuchElementError
    refresh_tries -= 1
    raise command_error if refresh_tries == 0
    sleep wait_time
    # kaikifs.click_and_wait "refresh"
    retry
  end
end

# WD
When /^I open a doc search$/ do
  kaikifs.switch_to.default_content
  kaikifs.click_and_wait(:xpath, "//a[@class='portal_link' and @title='Document Search']")
  kaikifs.select_frame "iframeportlet"
end

# WD
When /^I click the "([^"]*)" portal link$/ do |link|
  kaikifs.click_and_wait(:link_text, link)
  kaikifs.select_frame "iframeportlet"
end

# WD
When /^I click "([^"]*)"$/ do |link|
  if link == 'create new'
    kaikifs.click_and_wait :xpath, "//img[@alt='#{link}']"
  elsif ['approve', 'cancel', 'disapprove', 'search', 'submit'].include? link
    kaikifs.click_and_wait :xpath, "//input[@title='#{link}']"
  elsif ['calculate'].include? link  # titleize or capitalize... this remains to be seen
    kaikifs.click_and_wait :xpath, "//input[@title='#{link.titleize}']"
  elsif ['get document'].include? link
    kaikifs.click_and_wait :name, "methodToCall.#{link.gsub(/ /, '_').camelize(:lower)}"
  elsif link == 'yes'
    kaikifs.click_and_wait :name, 'methodToCall.processAnswer.button0'
  elsif link == 'no'
    kaikifs.click_and_wait :name, 'methodToCall.processAnswer.button1'
  else
    raise NotImplementedError
  end
end

# Clicks a button based on its name
When /^I click the "([^"]*)" submit button$/ do |action|
    kaikifs.click_and_wait :name, "methodToCall.#{action.gsub(/ /, '').camelize(:lower)}"
end

# WD
When /^I click "([^"]*)" with reason "([^"]*)"$/ do |link, reason|
  if ['disapprove'].include? link
    kaikifs.click_and_wait :xpath, "//input[@title='#{link}']"
  end
  kaikifs.set_field("//*[@name='reason']", reason)
  kaikifs.click_and_wait :name, 'methodToCall.processAnswer.button0'  # The 'yes' button
end

# WD
When /^I start a lookup for "([^"]*)"$/ do |field|
  kaikifs.click_approximate_and_wait(
    [
      "//div[contains(text(), '#{field}')]/../following-sibling::*/input[@title='Search ']",
      "//div[contains(text()[1], '#{field}')]/../following-sibling::*/input[@title='Search ']",
      "//div[contains(text()[2], '#{field}')]/../following-sibling::*/input[@title='Search ']",
      "//div[contains(text()[3], '#{field}')]/../following-sibling::*/input[@title='Search ']",
      # The following appear on lookups like the Person Lookup. Like doc search > Initiator Lookup
      "//th/label[contains(text(), '#{field}')]/../following-sibling::td/input[contains(@title, 'Search ')]"
    ]
  )
end

# WD
When /^I start a lookup for the new ([^']*)'s "([^"]*)"$/ do |tab, field|
  #kaikifs.click_and_wait("xpath=//*[@id='tab-#{object}-div']//div[contains(text(), '#{field}')]/../following-sibling::*/input[@title='Search ']")
  div = "tab-#{tab.pluralize}-div"
  kaikifs.click_approximate_and_wait(
    [
      "//*[@id='#{div}']//div[contains(text(), '#{field}:')]/../following-sibling::*/input[@title='Search ']",
      "//*[@id='#{div}']//th[contains(text(), '#{field}')]/../following-sibling::tr//input[@title='Search ']",
      "//*[@id='#{div}']//th[contains(text()[1], '#{field}')]/../following-sibling::tr//input[@title='Search ']",
      "//*[@id='#{div}']//th[contains(text()[2], '#{field}')]/../following-sibling::tr//input[@title='Search ']", # Group > create new > set Group Namespace > Assignees
      "//*[@id='#{div}']//th[contains(text()[3], '#{field}')]/../following-sibling::tr//input[@title='Search ']"
    ])
end

# WD
When /^I (?:return(?: with)?|open) the first (?:result|one)$/ do
  kaikifs.highlight(:xpath, "//table[@id='row']/tbody/tr/td/a", 4)
  sleep 5
  kaikifs.click_and_wait(:xpath, "//table[@id='row']/tbody/tr/td/a")
end

# WD
# Matches  I return the...
#          I return with the ...
#          I open the...
When /^I (?:return(?: with)?|open) the "([^"]*)" (?:result|one)$/ do |key|
  kaikifs.click_and_wait(:xpath, "//a[contains(text(), '#{key}')]/ancestor::tr/td[1]/a")
end

#When /^I edit the "([^"]*)" one$/ do |key|
#  kaikifs.click_and_wait("xpath=//a[contains(text(), '#{key}')]/ancestor::tr/td[1]/a[contains(@title,'edit')]")
#end

# WD
When /^I edit the first one$/ do
  kaikifs.click_and_wait(:xpath, "//table[@id='row']/tbody/tr/td[1]/a[contains(@title,'edit')]")
end

# WD
When /^I open that document$/ do
  doc_nbr = kaikifs.record[:document_number]
  kaikifs.click_and_wait(:xpath, "//a[contains(text(), '#{doc_nbr}')]")
end

# WD
Given /^I am fast$/ do
  kaikifs.pause = 0
end

# WD
When /^I slow down$/ do
  kaikifs.pause += 2
end

# WD
When /^I sleep for "([^"]*)" seconds$/ do |seconds|
  sleep seconds.to_i
end

# WD
When /^I pause$/ do
  sleep 30
end

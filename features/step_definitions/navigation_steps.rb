Given /^I am up top$/ do
  kaikifs.select_frame("relative=up")
  #kaikifs.select_frame("top")
end

Given /^I am on the "([^"]*)" tab$/ do |tab|
  kaikifs.send("#{tab}_panel".to_sym)
end

When /^I open my Action List$/i do
  kaikifs.click_and_wait("xpath=//a[@class='portal_link' and @title='Action List']")
end

When /^I open my Action List, refreshing until that document appears$/i do
  steps %{
    When I open my Action List
    And  I wait for that document to appear in my Action List
  }
end

When /^I wait for that document to appear in my Action List$/i do
  doc_nbr = kaikifs.record[:document_number]
  refresh_tries = 5
  wait_time = 6
  begin
    kaikifs.get_text("xpath=//a[contains(text(), '#{doc_nbr}')]")
  rescue Selenium::CommandError => command_error
    refresh_tries -= 1
    raise command_error if refresh_tries == 0
    sleep wait_time
    retry
  end
end

When /^I open a doc search$/ do
  kaikifs.click_and_wait("xpath=//a[@class='portal_link' and @title='Document Search']")
  kaikifs.select_frame "iframeportlet"
end

When /^I click the "([^"]*)" portal link$/ do |link|
  kaikifs.click_and_wait "link=#{link}"
  kaikifs.select_frame "iframeportlet"
end

When /^I click "([^"]*)"$/ do |arg1|
  if (arg1 == "create new")
    kaikifs.click_and_wait "css=img[alt=create new]"
  end
end

When /^I click "([^"]*)" and wait$/ do |link|
  if ['approve', 'calculate', 'cancel', 'route', 'search'].include? link
    kaikifs.click_and_wait "methodToCall.#{link}"
  elsif link == 'yes'
    kaikifs.click_and_wait "name=methodToCall.processAnswer.button0"
  elsif link == 'no'
    kaikifs.click_and_wait "name=methodToCall.processAnswer.button1"
  else
    raise StandardError  # raise something better than this!!!
  end
end

When /^I click "([^"]*)" with reason "([^"]*)" and wait$/ do |link, reason|
  if ['disapprove'].include? link
    kaikifs.click_and_wait "methodToCall.#{link}"
  end
  kaikifs.set_field("//*[@name='reason']", reason)
  kaikifs.click_and_wait "name=methodToCall.processAnswer.button0"  # The 'yes' button
end

When /^I start a lookup for "([^"]*)"$/ do |field|
  kaikifs.click_approximate_and_wait(
    [
      "xpath=//div[contains(text(), '#{field}')]/../following-sibling::*/input[@title='Search ']",
      "xpath=//div[contains(text()[1], '#{field}')]/../following-sibling::*/input[@title='Search ']",
      "xpath=//div[contains(text()[2], '#{field}')]/../following-sibling::*/input[@title='Search ']",
      "xpath=//div[contains(text()[3], '#{field}')]/../following-sibling::*/input[@title='Search ']",
      # The following appear on lookups like the Person Lookup. Like doc search > Initiator Lookup
      "xpath=//th/label[contains(text(), '#{field}')]/../following-sibling::td/input[contains(@title, 'Search ')]"
    ]
  )
#  kaikifs.click_and_wait(<<-JAVASCRIPT
#    dom=(
#      function() {
#        var iframeportlet = document.getElementById("iframeportlet");
#        var label = iframeportlet.contentDocument.evaluate("//div[contains(text(),'#{field}')]", iframeportlet.contentDocument, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
#        var cell = label.parentNode.nextSibling;
#        if (cell.nodeName == "#text") { cell = cell.nextSibling; }
#        lookupButton = iframeportlet.contentDocument.evaluate("//input[@title='Search ']", cell, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
#        return lookupButton;
#      }
#    )()
#  JAVASCRIPT
#                      )
end

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

When /^I return with the first result$/ do
  kaikifs.click_and_wait("xpath=//table[@id='row']/tbody/tr/td/a")
end

When /^I return(?: with)? the "([^"]*)" one$/ do |key|
  #kaikifs.click_and_wait("xpath=//a[contains(text(), '#{key}')]")
  kaikifs.click_and_wait("xpath=//a[contains(text(), '#{key}')]/ancestor::tr/td[1]/a")
end

When /^I edit the "([^"]*)" one$/ do |key|
  kaikifs.click_and_wait("xpath=//a[contains(text(), '#{key}')]/ancestor::tr/td[1]/a[contains(@title,'edit')]")
end

When /^I edit the first one$/ do
  kaikifs.click_and_wait("xpath=//table[@id='row']/tbody/tr/td[1]/a[contains(@title,'edit')]")
end

When /^I open that document$/ do
  doc_nbr = kaikifs.record[:document_number]
  kaikifs.click_and_wait("xpath=//a[contains(text(), '#{doc_nbr}')]")
end

Given /^I am fast$/ do
  kaikifs.pause = 0
end

When /^I slow down$/ do
  kaikifs.pause += 2
end

When /^I sleep for "([^"]*)" seconds$/ do |seconds|
  sleep seconds.to_i
end

When /^I pause$/ do
  sleep 30
end

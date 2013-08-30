Then /^I should see my Action List$/ do
  kaikifs.pause(1)
  kaikifs.should have_content("Action List")
end

Then /^I should see "([^"]*)"$/ do |text|
  kaikifs.pause(1)
  kaikifs.should have_content(text)
end

# WD
Then /^I should see the message "([^"]*)"$/ do |text|
  kaikifs.pause(1)
  kaikifs.wait_for(:xpath, "//div[@class='msg-excol']")
  kaikifs.should have_content(text)
end

# WD
Then /^I should see "([^"]*)" in the "([^"]*)" iframe$/ do |text, frame|
  kaikifs.select_frame(frame+"IFrame")
  wait = Selenium::WebDriver::Wait.new(:timeout => 8)
  wait.until { kaikifs.find_element(:xpath, "//div[@id='workarea']") }
  kaikifs.should have_content(text)
  kaikifs.switch_to.default_content
  kaikifs.select_frame("iframeportlet")
end

# WD
Then /^I should see "([^"]*)" in the route log$/ do |text|
  refresh_tries = 5
  wait_time = 1

  kaikifs.select_frame("routeLogIFrame")
  begin
    wait = Selenium::WebDriver::Wait.new(:timeout => 4).
      until { kaikifs.find_element(:xpath, "//div[@id='workarea']") }
    if kaikifs.has_content? text
      kaikifs.should have_content(text)
    end
  rescue Selenium::WebDriver::Error::TimeOutError => command_error
    puts "#{refresh_tries} retries left... #{Time.now}"
    refresh_tries -= 1
    if refresh_tries == 0
      kaikifs.should have_content(text)
    end

    kaikifs.click_and_wait :alt, "refresh"  # 'refresh'
    kaikifs.pause wait_time
    retry
  ensure
    kaikifs.switch_to.default_content
    kaikifs.select_frame("iframeportlet")
  end
end

Then /^I should see "([^"]*)" in "([^"]*)"$/ do |text, el|
  kaikifs.select_frame("iframeportlet")
  puts kaikifs.wait_for_text(text, :element => el, :timeout_in_seconds => 30);
  kaikifs.switch_to.default_content
end

Then /^I shouldn't get an HTTP Status (\d+)$/ do |status_no|
  kaikifs.should_not have_content("HTTP Status #{status_no}")
end

# WD
Then /^I shouldn't see an incident report/ do
  kaikifs.should_not have_content('Incident Report')
end

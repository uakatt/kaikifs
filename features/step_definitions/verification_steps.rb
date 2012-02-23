Then /^I should see my Action List$/ do
  kaikifs.pause(1)
  kaikifs.wait_for(:xpath, "//div[@id='headerarea-small']")
  kaikifs.is_text_present("Action List").should == true
end

Then /^I should see "([^"]*)"$/ do |text|
  kaikifs.pause(1)
  kaikifs.is_text_present(text).should == true
end

# WD
Then /^I should see the message "([^"]*)"$/ do |text|
  kaikifs.pause(1)
  kaikifs.wait_for(:xpath, "//div[@class='msg-excol']")
  kaikifs.is_text_present(text, "//div[@class='msg-excol']/div/div").should == true
end

# WD
Then /^I should see "([^"]*)" in the "([^"]*)" iframe$/ do |text, frame|
  kaikifs.select_frame(frame+"IFrame")
  kaikifs.is_text_present(text).should == true
  kaikifs.switch_to.default_content
  kaikifs.pause(1)
  kaikifs.select_frame("iframeportlet")
end

Then /^I should see "([^"]*)" in "([^"]*)"$/ do |text, el|
  kaikifs.select_frame("iframeportlet")
  puts kaikifs.wait_for_text(text, :element => el, :timeout_in_seconds => 30);
  kaikifs.switch_to.default_content
  kaikifs.pause(1)
end

Then /^I shouldn't get an HTTP Status (\d+)$/ do |status_no|
  if status_no == '500'
    kaikifs.pause(1)
    kaikifs.is_text_present('HTTP Status 500').should_not == true
  end
end

Then /^I shouldn't see an incident report/ do
  kaikifs.pause(1)
  kaikifs.is_text_present('Incident Report').should_not == true
end

Then /^I should see "([^"]*)"$/ do |text|
  kaikifs.is_text_present(text).should == true
end

Then /^I should see "([^"]*)" in the "([^"]*)" iframe$/ do |text, frame|
  kaikifs.select_frame(frame+"IFrame")
  kaikifs.is_text_present(text).should == true
  kaikifs.select_frame("relative=up")
end

Then /^I should see "([^"]*)" in "([^"]*)"$/ do |text, el|
  kaikifs.select_frame("iframeportlet")
  puts kaikifs.wait_for_text(text, :element => el, :timeout_in_seconds => 30);
  kaikifs.select_frame("relative=up")
end

Then /^I shouldn't get an HTTP Status (\d+)$/ do |status_no|
  if status_no == '500'
    kaikifs.is_text_present('HTTP Status 500').should_not == true
  end
end

Then /^I shouldn't see an incident report/ do
  kaikifs.is_text_present('Incident Report').should_not == true
end

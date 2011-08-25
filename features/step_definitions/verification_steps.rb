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

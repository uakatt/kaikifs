Given /^I am up top$/ do
  kaikifs.select_frame("relative=up")
  #kaikifs.select_frame("top")
end

Given /^I am on the "([^"]*)" tab$/ do |tab|
  kaikifs.send("#{tab}_panel".to_sym)
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
  case link
  when "route"
    kaikifs.click_and_wait "methodToCall.route"
  when "yes"
    kaikifs.click_and_wait "name=methodToCall.processAnswer.button0"
  when "no"
    kaikifs.click_and_wait "name=methodToCall.processAnswer.button1"
  end
  
end

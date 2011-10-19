When /^I hide the "([^"]*)" tab$/ do |tab|
  kaikifs.hide_tab tab
end

When /^I show the "([^"]*)" tab$/ do |tab|
  kaikifs.show_tab tab
  sleep 2
end

# WD
When /^I click "([^"]*)" under (.*)$/ do |button, tab|
  case
  when button =~ /inactive/
    kaikifs.click_and_wait(:xpath, "//h2[contains(text(), '#{tab}')]/../following-sibling::*//input[contains(@title, 'inactive')]")
  end
end

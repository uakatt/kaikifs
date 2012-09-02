# WD
When /^I hide the "([^"]*)" tab$/ do |tab|
  kaikifs.hide_tab tab
end

# WD
When /^I show the "([^"]*)" tab$/ do |tab|
  kaikifs.show_tab tab
end

When /^I show the ([0-9a-z]+) Item's "([^"]*)"/i do |ordinal, tab|
  numeral = EnglishNumbers::ORDINAL_TO_NUMERAL[ordinal]
  xpath = "//td[contains(text(), 'Item #{numeral}')]/../following-sibling::tr//div[contains(text()[2], '#{tab}')]//input"
  kaikifs.click_and_wait(:xpath, xpath)
end

# WD
When /^I click "([^"]*)" under (.*)$/ do |button, tab|
  case
  when button =~ /inactive/
    kaikifs.click_and_wait(:xpath, "//h2[contains(text(), '#{tab}')]/../following-sibling::*//input[contains(@title, 'inactive')]")
  end
end

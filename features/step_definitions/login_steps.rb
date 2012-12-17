# WD
Given /^I (?:am backdoored|backdoor) as "([^"]*)"$/ do |user|
  kaikifs.backdoor_as user
end

# WD
Given /^I (?:am backdoored|backdoor) as the (.*)$/ do |title|
  user = kaikifs.user_by_title(title)
  puts "The #{title} is #{user}"
  kaikifs.backdoor_as user
end

# WD
Given /^I (?:am logged in|log in)$/ do
  kaikifs.backdoor_as kaikifs.username
end

# WD
Given /^I (?:am logged in|log in) as "([^"]*)"$/ do |user|
  kaikifs.login_as user
end

# WD
Given /^I (?:am logged in|log in) as the (.*)$/ do |title|
  user = kaikifs.user_by_title(title)
  puts "The #{title} is #{user}"
  kaikifs.login_as user
end

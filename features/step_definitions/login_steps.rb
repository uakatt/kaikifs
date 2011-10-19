# WD
Given /^I (?:am backdoored|backdoor) as "([^"]*)"$/ do |user|
  kaikifs.backdoor_as user
end

# WD
Given /^I (?:am logged in|log in)$/ do
  kaikifs.backdoor_as kaikifs.username
end

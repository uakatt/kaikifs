Then /^I print "([^"]*)"$/ do |ruby|
  result = eval(ruby)
  pp result
  kaikifs.log.debug result.inspect
end

Then /^I print (?:all|each) "([^"]*)"$/ do |ruby|
  result = eval(ruby)
  result.each do |e|
    pp e
  end
  kaikifs.log.debug result.inspect
end

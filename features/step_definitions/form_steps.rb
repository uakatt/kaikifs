When /^I set "([^"]*)" to "([^"]*)"$/ do |field, value|
  kaikifs.set_field(field, value)
end

When /^I set "([^"]*)" in the "([^"]*)" to "([^"]*)"$/ do |field, area, value|
  if area == "documentHeader"
    kaikifs.set_field("document.#{area}.#{field}", value)
    sleep 4
  end
end

When /^I set "([^"]*)" in the "([^"]*)" to something like "([^"]*)"$/ do |field, area, value|
  if area == "documentHeader"
    kaikifs.set_field("document.#{area}.#{field}", "#{value} #{Time.now}")
    sleep 4
  end
end

When /^I set the new "([^"]*)"( radio)? to "([^"]*)"$/ do |field, radio, value|
  v = value.gsub(/#\{(\d+)i\}/) do |m|
    m =~ /(\d+)/
    d = $1.to_i
    (rand*(10**d)).to_i
  end
  if radio
    locator="name=document.newMaintainableObject.#{field} value=#{v}"
    kaikifs.set_field(locator)
  else
    kaikifs.set_field("document.newMaintainableObject."+field, v)
  end
end

When /^I set the new "([^"]*)" to something like "([^"]*)"$/ do |field, value|
  kaikifs.set_field("document.newMaintainableObject."+field, "#{value} #{Time.now.to_i}")
end

# "an additional" means 'document.newMaintainableObject.add'
# TODO At some point, refactor vendorAddress to be a variable!!
When /^I set an additional vendorAddress's "([^"]*)" to "([^"]*)"$/ do |field, value|
    childCollection = "vendorAddresses"  # document.newMaintainableObject.add.vendorAddresses.vendorLine1Address
    kaikifs.set_field("document.newMaintainableObject.add.#{childCollection}."+field, value)
end

When /^I add that (\S+) and wait$/ do |child|
  addButton = case child
    when 'vendorAddress' then 'methodToCall.addLine.vendorAddresses.(!!org.kuali.kfs.vnd.businessobject.VendorAddress!!)'
    end
  kaikifs.click_and_wait addButton
end

# TODO At some point, refactor first to be a variable!!
When /^I set the first (\S+)'s additional (\S+)'s "([^"]*)" to "([^"]*)"$/ do |child, childsChild, field, value|
  childElement = "#{child}es[0]"
  childElementsChild = "#{childsChild}es"
  # document.newMaintainableObject.add.vendorAddresses[0].vendorDefaultAddresses.vendorCampusCode
  kaikifs.set_field("document.newMaintainableObject.add.#{childElement}.#{childElementsChild}.#{field}", value)
end

When /^I add that first (\S+)'s (\S+) and wait$/ do |child, childsChild|
  addButton = case child
    when 'vendorAddress' then "methodToCall.addLine.vendorAddresses[0].#{childsChild.pluralize}.(!!org.kuali.kfs.vnd.businessobject.#{childsChild.camelize}!!)"
    end
  kaikifs.click_and_wait addButton
end

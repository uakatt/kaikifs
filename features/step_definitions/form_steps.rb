# The idea is to find a div containing the "label" text first. Then the field should be in the cell immediately to the right, or immediately below.

When /^I set the "([^"]*)" to "([^"]*)"$/ do |field, value|
  kaikifs.set_approximate_field(
    [
      "//div[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //div[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
      # The following are for horrible places in KFS where the text in a th might not be the first text() node.
      "//th[contains(text(), '#{field}')]",     # INCOMPLETE
      "//th[contains(text()[1], '#{field}')]",  # INCOMPLETE
      "//th[contains(text()[2], '#{field}')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
      "//th[contains(text()[3], '#{field}')]",  # INCOMPLETE
      # The following appear on lookups like the Person Lookup. Like Group > create new > Assignee Lookup (find a shorter path to Person Lookup)
      "//th/label[contains(text(), '#{field}')]/../following-sibling::td/input[1]",
      "//th/div[contains(text(), '#{field}')]/../following-sibling::td/input[1]",
      "//th/div[contains(text([1]), '#{field}')]/../following-sibling::td/input[1]",
      "//th/div[contains(text()[2], '#{field}')]/../following-sibling::td/input[1]"
    ],
    #ApproximationsFactory.build(
    #  "//%s[contains(text()%s, '%s')]/../following-sibling::td/%s"
    #  ['th/label', 'th/div'],
    #  ['', '[1]', '[2]', '[3]'],
    #  [field],
    #  ['select[1]', 'input[1]'])

    #ApproximationsFactory.transpose_build(
    #  "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
    #  ['th/label',  '',     'select[1]'],
    #  ['th/div',    '[1]',  'input[1]'],
    #  [nil,         '[2]',  nil],
    #  [nil,         '[3]',  nil]),
    value)
end

When /^I set the "([^"]*)" to "([^"]*)" and wait$/ do |field, value|
  kaikifs.set_approximate_field(
    [
      "//div[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //div[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
      # The following are for horrible places in KFS where the text in a th might not be the first text() node.
      "//th[contains(text(), '#{field}')]",     # INCOMPLETE
      "//th[contains(text()[1], '#{field}')]",  # INCOMPLETE
      "//th[contains(text()[2], '#{field}')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
      "//th[contains(text()[3], '#{field}')]",  # INCOMPLETE
      # The following appear on lookups like the Person Lookup. Like Group > create new > Assignee Lookup (find a shorter path to Person Lookup)
      "//th/label[contains(text(), '#{field}')]/../following-sibling::td/input[1]"
    ],
    value)
  kaikifs.wait_for_page_to_load
end

When /^I set the "([^"]*)" to something like "([^"]*)"$/ do |field, value|
  value = value + ' ' + Time.now.strftime("%Y%m%d%H%M%S")
  kaikifs.set_approximate_field(
    [
      "//div[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //div[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
      # The following are for horrible places in KFS where the text in a th might not be the first text() node.
      "//th[contains(text(), '#{field}')]",     # INCOMPLETE
      "//th[contains(text()[1], '#{field}')]",  # INCOMPLETE
      "//th[contains(text()[2], '#{field}')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
      "//th[contains(text()[3], '#{field}')]",  # INCOMPLETE
      # The following appear on lookups like the Person Lookup. Like Group > create new > Assignee Lookup (find a shorter path to Person Lookup)
      # Also like Document Description
      "//th/label[contains(text(), '#{field}')]/../following-sibling::td/input[1]",
      "//th/label[contains(text()[1], '#{field}')]/../following-sibling::td/input[1]",  # Vendor > create new > Document Overview Description
      "//th/label[contains(text()[2], '#{field}')]/../following-sibling::td/input[1]"
    ],
    value)
end

# For example, Vendor > create new; the Vendor Name through Default Payment Method fields
When /^I set the new "([^"]*)" to "([^"]*)"$/ do |field, value|

  kaikifs.set_approximate_field(
    [
      "//div[contains(text(), '#{field}:') and contains(@id, '.newMaintainableObject.')]/../following-sibling::*/select[1] |" +
        " //div[contains(text(), '#{field}:')]/../following-sibling::*/input[1]",
      # The following are for horrible places in KFS where the text in a th might not be the first text() node.
      "//th[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]",     # INCOMPLETE
      "//th[contains(text()[1], '#{field}') and contains(@id, '.newMaintainableObject.')]",  # INCOMPLETE
      "//th[contains(text()[2], '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
      "//th[contains(text()[3], '#{field}') and contains(@id, '.newMaintainableObject.')]",  # INCOMPLETE
      # The following appear on lookups like the Person Lookup. Like Group > create new > Assignee Lookup (find a shorter path to Person Lookup)
      "//th/label[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::td/select[1]",
      "//th/label[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::td/input[1]"
    ],
    value)
end

# For example, Vendor > create new; the Tax Number Type field
When /^I set the new "([^"]*)" radio to "([^"]*)"$/ do |field, value|
  kaikifs.set_approximate_field(
    [
      "//div[contains(text(), '#{field}:') and contains(@id, '.newMaintainableObject.')]/../following-sibling::*/input[@value='#{value}']",
      # The following are for horrible places in KFS where the text in a th might not be the first text() node.
      "//th[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]",     # INCOMPLETE
      "//th[contains(text()[1], '#{field}') and contains(@id, '.newMaintainableObject.')]",  # INCOMPLETE
      "//th[contains(text()[2], '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
      "//th[contains(text()[3], '#{field}') and contains(@id, '.newMaintainableObject.')]",  # INCOMPLETE
      # The following appear on lookups like the Person Lookup. Like Group > create new > Assignee Lookup (find a shorter path to Person Lookup)
      "//th/label[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::td/input[@value='#{value}']"
    ],
    value)
end

When /^I set a new ([^']*)'s "([^"]*)" to "([^"]*)"$/ do |tab, field, value|
  object = tab.pluralize  # Assignee  -->  Assignees
  div = "tab-#{object}-div"
  kaikifs.set_approximate_field(
    [
      "//*[@id='#{div}']//div[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //div[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
      "//*[@id='#{div}']//th[contains(text(), '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]",
      "//*[@id='#{div}']//th[contains(text()[1], '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]",
      "//*[@id='#{div}']//th[contains(text()[2], '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]", # Group > create new > set Group Namespace > Assignees
      "//*[@id='#{div}']//th[contains(text()[3], '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]"
    ],
    value)
end

# OLD SCHOOL
When /^I set "([^"]*)" to "([^"]*)"$/ do |field, value|
  kaikifs.set_field(field, value)
end

# OLD SCHOOL
When /^I set "([^"]*)" in the "([^"]*)" to "([^"]*)"$/ do |field, area, value|
  if area == "documentHeader"
    kaikifs.set_field("document.#{area}.#{field}", value)
    sleep 4
  end
end

# OLD SCHOOL
When /^I set "([^"]*)" in the "([^"]*)" to something like "([^"]*)"$/ do |field, area, value|
  if area == "documentHeader"
    kaikifs.set_field("document.#{area}.#{field}", "#{value} #{Time.now}")
    sleep 4
  end
end

#When /^I set the new "([^"]*)"( radio)? to "([^"]*)"$/ do |field, radio, value|
#  v = value.gsub(/#\{(\d+)i\}/) do |m|
#    m =~ /(\d+)/
#    d = $1.to_i-1
#    (rand*(9*10**d) + 10**d).to_i
#  end
#  if radio
#    locator="name=document.newMaintainableObject.#{field} value=#{v}"
#    kaikifs.set_field(locator)
#  else
#    kaikifs.set_field("document.newMaintainableObject."+field, v)
#  end
#end

When /^I set the new "([^"]*)" to something like "([^"]*)"$/ do |field, value|
  kaikifs.set_field("document.newMaintainableObject."+field, "#{value} #{Time.now.to_i}")
end

When /^I (check|uncheck) the "([^"]*)" for the new "([^"]*)"$/ do |check, field, child|
  div = case
        when child == 'Search Alias' then 'tab-SearchAlias-div'
        else                              "tab-#{child.pluralize}-div"
        end
  xpath = "xpath=//*[@id='#{div}']//th/label[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::td/input[1]"
  kaikifs.send(check.to_sym, xpath)
end

# DEPRECATED
# "an additional" means 'document.newMaintainableObject.add'
When /^I set an additional vendorAddress's "([^"]*)" to "([^"]*)"$/ do |field, value|
    childCollection = "vendorAddresses"  # document.newMaintainableObject.add.vendorAddresses.vendorLine1Address
    kaikifs.set_field("document.newMaintainableObject.add.#{childCollection}."+field, value)
end

When /^I add that "([^"]*)" and wait$/ do |child|
  addButton = case
    when child =~ /Vendor Address|vendorAddress/  # A new vendor fieldset has no id.
      'methodToCall.addLine.vendorAddresses.(!!org.kuali.kfs.vnd.businessobject.VendorAddress!!)'
    else
      div = case
            when child == 'Search Alias' then 'tab-SearchAlias-div'
            else                              "tab-#{child.pluralize}-div"
            end
      # click the (only) add button in the right tab. Example: Group > create new > Assignees
      "xpath=//*[@id='#{div}']//input[contains(@src, 'add1.gif')]"  # hard-coding add1.gif until we need another image.
                                                                    # I don't just want to rely on 'add' yet...
    end
  kaikifs.click_and_wait addButton
end

# DEPRECATED
When /^I set the first (\S+)'s additional (\S+)'s "([^"]*)" to "([^"]*)"$/ do |child, childsChild, field, value|
  childElement = "#{child}es[0]"
  childElementsChild = "#{childsChild}es"
  # document.newMaintainableObject.add.vendorAddresses[0].vendorDefaultAddresses.vendorCampusCode
  kaikifs.set_field("document.newMaintainableObject.add.#{childElement}.#{childElementsChild}.#{field}", value)
end

When /^I set the first Vendor Address as the campus default for "([^"]*)"$/ do |value|
  kaikifs.set_field("document.newMaintainableObject.add.vendorAddresses[0].vendorDefaultAddresses.vendorCampusCode", value)
  kaikifs.record['current_vendor_address'] = 'vendorAddresses[0]'
end

When /^I add that Default Address and wait/i do
  vendor_address = kaikifs.record['current_vendor_address']
  kaikifs.click_and_wait "methodToCall.addLine.#{vendor_address}.vendorDefaultAddresses.(!!org.kuali.kfs.vnd.businessobject.VendorDefaultAddress!!)"
end

#DEPRECATED
When /^I add that first (\S+)'s (\S+) and wait$/ do |child, childsChild|
  addButton = case child
    when 'vendorAddress' then "methodToCall.addLine.vendorAddresses[0].#{childsChild.pluralize}.(!!org.kuali.kfs.vnd.businessobject.#{childsChild.camelize}!!)"
    end
  kaikifs.click_and_wait addButton
end

When /^I fill out a new (?:Vendor Address|vendorAddress) with default values$/ do
  prefix = "document.newMaintainableObject.add.vendorAddresses."
  kaikifs.set_field(prefix+'vendorAddressTypeCode', 'PURCHASE ORDER')
  kaikifs.set_field(prefix+'vendorLine1Address', '123 main St.')
  kaikifs.set_field(prefix+'vendorCityName', 'Tucson')
  kaikifs.set_field(prefix+'vendorStateCode', 'AZ')
  kaikifs.set_field(prefix+'vendorZipCode', '85719')
  kaikifs.set_field(prefix+'vendorCountryCode', 'UNITED STATES')
  kaikifs.set_field(prefix+'vendorDefaultAddressIndicator', 'Yes')
end

When /^I fill out a new Item with default values$/ do
  prefix = "newPurchasingItemLine."
  kaikifs.set_field(prefix+'itemTypeCode', 'QUANTITY TAXABLE')
  kaikifs.set_field(prefix+'itemQuantity', '42')            # Meaning of Life, the Universe, and Everything
  kaikifs.set_field(prefix+'itemUnitOfMeasureCode', 'BDL')  # Bundle
  kaikifs.set_field(prefix+'itemDescription', 'Surprises')
  kaikifs.set_field(prefix+'itemUnitPrice', '3.14')
end

When /^I fill out a new (Vendor Address|vendorAddress) with the following:$/ do |table|
  fields = table.rows_hash
  prefix = "document.newMaintainableObject.add.vendorAddresses."
  fields.each do |key, value|
    kaikifs.set_field(prefix+key, value)
  end
end

Transform /#\{\d+i\}/ do |v|
  v.gsub(/#\{(\d+)i\}/) do |m|
    m =~ /(\d+)/
    d = $1.to_i-1
    (rand*(9*10**d) + 10**d).to_i
  end
end

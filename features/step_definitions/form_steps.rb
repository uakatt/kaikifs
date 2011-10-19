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
      "//th/div[contains(text()[1], '#{field}')]/../following-sibling::td/input[1]",
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

# WD
When /^I set the "([^"]*)" to something like "([^"]*)"$/ do |field, value|
  value = value + ' ' + Time.now.strftime("%Y%m%d%H%M%S")
  kaikifs.set_approximate_field(
    [
      "//div[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //div[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
      # The following appear on lookups like the Person Lookup. Like Group > create new > Assignee Lookup (find a shorter path to Person Lookup)
      # Also like Document Description
      "//th/label[contains(text(), '#{field}')]/../following-sibling::td/input[1]",
      "//th/label[contains(text()[1], '#{field}')]/../following-sibling::td/input[1]",  # Vendor > create new > Document Overview Description
      "//th/label[contains(text()[2], '#{field}')]/../following-sibling::td/input[1]",
      # The following are for horrible places in KFS where the text in a th might not be the first text() node.
      "//th[contains(text(), '#{field}')]",     # INCOMPLETE
      "//th[contains(text()[1], '#{field}')]",  # INCOMPLETE
      "//th[contains(text()[2], '#{field}')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
      "//th[contains(text()[3], '#{field}')]"   # INCOMPLETE
    ],
    value)
end

# WD
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
  object =
    case tab
    when 'Address' then 'Address'
    else                tab.pluralize  # Assignee  -->  Assignees
    end
  div = "tab-#{object}-div"
  kaikifs.set_approximate_field(
    [
      "//*[@id='#{div}']//div[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //div[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
      "//*[@id='#{div}']//th/label[contains(text(), '#{field}')]/../following-sibling::td//select[1]",  # Vendor > create new > new Address > Address Type
      "//*[@id='#{div}']//th/label[contains(text(), '#{field}')]/../following-sibling::td//input[1]",   # Vendor > create new > new Address > Address 1
      "//*[@id='#{div}']//th[contains(text(), '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]",
      "//*[@id='#{div}']//th[contains(text()[1], '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]",
      "//*[@id='#{div}']//th[contains(text()[2], '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]", # Group > create new > set Group Namespace > Assignees
      "//*[@id='#{div}']//th[contains(text()[3], '#{field}')]/../following-sibling::tr//*[contains(@title, '#{field}')]"
    ],
    value)
end

When /^I set the new "([^"]*)" to something like "([^"]*)"$/ do |field, value|
  kaikifs.set_field("document.newMaintainableObject."+field, "#{value} #{Time.now.to_i}")
end

When /^I (check|uncheck) the "([^"]*)" for the new "([^"]*)"$/ do |check, field, child|
  div = case
        when child == 'Search Alias' then 'tab-SearchAlias-div'
        else                              "tab-#{child.pluralize}-div"
        end
  xpath = "//*[@id='#{div}']//th/label[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::td/input[1]"
  kaikifs.send(check.to_sym, :xpath, xpath)
end

# WD
When /^I add that "([^"]*)" and wait$/ do |child|
  case
  when child =~ /Vendor Address|vendorAddress/  # A new vendor fieldset has no id.
    kaikifs.click_and_wait :id, 'methodToCall.addLine.vendorAddresses.(!!org.kuali.kfs.vnd.businessobject.VendorAddress!!)'
  else
    div =
      case
      when child == 'Search Alias' then 'tab-SearchAlias-div'
      else                              "tab-#{child.pluralize}-div"
      end

    # click the (only) add button in the right tab. Example: Group > create new > Assignees
    # hard-coding add1.gif until we need another image. I don't just want to rely on 'add' yet...
    add_button = case
      # The first 'input[contains(@src, 'add1.gif')] is the hidden 'import lines' add button.
      when child == 'Item' then "//div[@id='#{div}']//input[@title='Add an Item']"
      else                      "//div[@id='#{div}']//input[contains(@src, 'add1.gif')]"
      end
    kaikifs.click_and_wait :xpath, add_button
  end
end


When /^I set the first Vendor Address as the campus default for "([^"]*)"$/ do |value|
  kaikifs.set_field("document.newMaintainableObject.add.vendorAddresses[0].vendorDefaultAddresses.vendorCampusCode", value)
  kaikifs.record['current_vendor_address'] = 'vendorAddresses[0]'
end

When /^I add that Default Address and wait/i do
  vendor_address = kaikifs.record['current_vendor_address']
  kaikifs.click_and_wait :id, "methodToCall.addLine.#{vendor_address}.vendorDefaultAddresses.(!!org.kuali.kfs.vnd.businessobject.VendorDefaultAddress!!)"
end

# WD
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

When /^I fill out a new (?:Vendor Address|vendorAddress) with the following:$/ do |table|
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

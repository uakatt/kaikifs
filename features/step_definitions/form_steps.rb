# The idea is to find a div containing the "label" text first. Then the field should be in the cell immediately to the right, or immediately below.

# WD
When /^I set the "([^"]*)" to "([^"]*)"$/ do |field, value|
  kaikifs.set_approximate_field(
    ApproximationsFactory.transpose_build(
      "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
      ['th/label',    '',       'select[1]'],
      ['th/div',      '[1]',    'input[1]'],
      [nil,           '[2]',    nil]
    ) +
    ApproximationsFactory.transpose_build(
      "//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/%s[contains(@title, '#{field}')]",
      ['',       'select'],
      ['[1]',    'input'],
      ['[2]',    nil]
    ),
    value
  )
end

# WD
When /^I set the "([^"]*)" to "([^"]*)" if blank$/ do |field, value|
  current_value = kaikifs.get_approximate_field(
    ApproximationsFactory.transpose_build(
      "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
      ['th/label',    '',       'select[1]'],
      ['th/div',      '[1]',    'input[1]'],
      [nil,           '[2]',    nil]
    ) +
    ApproximationsFactory.transpose_build(
      "//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/%s[contains(@title, '#{field}')]",
      ['',       'select'],
      ['[1]',    'input'],
      ['[2]',    nil]
    ))

  if current_value.empty?
    puts "#{field} was blank."

    kaikifs.set_approximate_field(
      ApproximationsFactory.transpose_build(
        "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
        ['th/label',    '',       'select[1]'],
        ['th/div',      '[1]',    'input[1]'],
        [nil,           '[2]',    nil]
      ) +
      ApproximationsFactory.transpose_build(
        "//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/%s[contains(@title, '#{field}')]",
        ['',       'select'],
        ['[1]',    'input'],
        ['[2]',    nil]
      ),
      value)

  else
    puts "#{field} already had a value: '#{current_value}'."

  end
end

#When /^I set the "([^"]*)" to "([^"]*)" and wait$/ do |field, value|
#  kaikifs.set_approximate_field(
#    [
#      "//div[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //div[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
#      # The following are for horrible places in KFS where the text in a th might not be the first text() node.
#      "//th[contains(text(), '#{field}')]",     # INCOMPLETE
#      "//th[contains(text()[1], '#{field}')]",  # INCOMPLETE
#      "//th[contains(text()[2], '#{field}')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
#      "//th[contains(text()[3], '#{field}')]",  # INCOMPLETE
#      # The following appear on lookups like the Person Lookup. Like Group > create new > Assignee Lookup (find a shorter path to Person Lookup)
#      "//th/label[contains(text(), '#{field}')]/../following-sibling::td/input[1]"
#    ],
#    value)
#  kaikifs.wait_for_page_to_load
#end

# WD
When /^I set the "([^"]*)" to something like "([^"]*)"$/ do |field, value|
  value = value + ' ' + Time.now.strftime("%Y%m%d%H%M%S")
  kaikifs.set_approximate_field(
    ApproximationsFactory.transpose_build(
      "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
      ['th/label',    '',       'select[1]'],
      ['th/div',      '[1]',    'input[1]'],
      [nil,           '[2]',    nil]
    ),
    value
  )
end

# WD
When /^I set the "([^"]*)" to that "([^"]*)"$/ do |field, identifier|
  kaikifs.set_approximate_field(
    ApproximationsFactory.transpose_build(
      "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
      ['th/label',    '',       'select[1]'],
      ['th/div',      '[1]',    'input[1]'],
      [nil,           '[2]',    nil]
    ) +
    ApproximationsFactory.transpose_build(
      "//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/%s[contains(@title, '#{field}')]",
      ['',       'select'],
      ['[1]',    'input'],
      ['[2]',    nil]
    ),
    kaikifs.record[identifier]
  )
end

# WD
When /^I set the "([^"]*)" to now \(([^)]+)\)$/ do |field, time_format|
  kaikifs.set_approximate_field(
    ApproximationsFactory.transpose_build(
      "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
      ['th/label',    '',       'select[1]'],
      ['th/div',      '[1]',    'input[1]'],
      [nil,           '[2]',    nil]
    ) +
    ApproximationsFactory.transpose_build(
      "//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/%s[contains(@title, '#{field}')]",
      ['',       'select'],
      ['[1]',    'input'],
      ['[2]',    nil]
    ),
    Time.now.strftime(time_format)
  )
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

# WD
When /^I set a new ([^']*)'s "([^"]*)" to "([^"]*)"$/ do |tab, field, value|
  object =
    case tab
    when 'Address' then 'Address'
    else                tab.pluralize  # Assignee  -->  Assignees
    end
  div = "tab-#{object}-div"
  row =
    case tab
    when 'Item' then 'tr[2]'  # Specifically for a Requisition...
    else             'tr'
    end
  title =
    case field
    when 'UOM' then 'Unit Of Measure'  # On Requisition Items, it's actually Item Unit Of Measure Code
    else            field
    end
  kaikifs.set_approximate_field(
    ApproximationsFactory.transpose_build(
      "//*[@id='#{div}']//%s[contains(text()%s, '#{field}')]/../following-sibling::td//%s",
      ['div',       '',       'select[1]'],
      ['th/label',  '[1]',    'input[1]'],
      [nil,         '[2]',    nil]
    ) +
    ApproximationsFactory.build(
      "//*[@id='#{div}']//#{row}//th[contains(text()%s, '#{field}')]/../following-sibling::tr//*[contains(@title, '#{title}')]",
      ['', '[1]', '[2]', '[3]']
    ),
    value)
end

When /^I set the new "([^"]*)" to something like "([^"]*)"$/ do |field, value|
  kaikifs.set_field("document.newMaintainableObject."+field, "#{value} #{Time.now.to_i}")
end

When /^I set the "([^"]*)" to the given document number$/ do |field|
  doc_nbr = kaikifs.record[:document_number]
  kaikifs.set_approximate_field(
    ApproximationsFactory.transpose_build(
      "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
      ['th/label',    '',       'select[1]'],
      ['th/div',      '[1]',    'input[1]'],
      [nil,           '[2]',    nil]
    ) +
    ApproximationsFactory.transpose_build(
      "//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/%s[contains(@title, '#{field}')]",
      ['',       'select'],
      ['[1]',    'input'],
      ['[2]',    nil]
    ),
    doc_nbr
  )
end

# WD
When /^I (check|uncheck) "([^"]*)"$/ do |check, field|
  method = (check+'_approximate_field').to_sym

  if field == 'Immediate Pay'
    kaikifs.send(check, :xpath, "//input[@name='document.immediatePaymentIndicator']")
  else
    kaikifs.send(method,
      ApproximationsFactory.transpose_build(
        "//%s[contains(text()%s, '#{field}')]/../following-sibling::td/input[1]",
        ['th/label',    ''],
        ['th/div',      '[1]'],
        [nil,           '[2]']
      ) +
      ApproximationsFactory.transpose_build(
        "//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/input[1][contains(@title, '#{field}')]",
        [''],
        ['[1]'],
        ['[2]']
      )
    )
  end
end

# WD
When /^I (check|uncheck) the "([^"]*)" for the new "([^"]*)"$/ do |check, field, child|
  div = case
        when child == 'Search Alias' then 'tab-SearchAlias-div'
        else                              "tab-#{child.pluralize}-div"
        end
  xpath = "//*[@id='#{div}']//th/label[contains(text(), '#{field}') and contains(@id, '.newMaintainableObject.')]/../following-sibling::td/input[1]"
  kaikifs.send(check.to_sym, :xpath, xpath)
end

# WD
When /^I add that "([^"]*)"$/ do |child|
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

# WD
When /^I add that ([0-9a-z]+) Item's new Source Line$/i do |ordinal|
  numeral = EnglishNumbers::ORDINAL_TO_NUMERAL[ordinal]
  xpath = "//td[contains(text(), 'Item #{numeral}')]" +                                # The cell that contains only "Item 1"
          "/../following-sibling::tr//div[contains(text()[2], 'Accounting Lines')]" +  # Back up, drop down a row, find the "Acounting Lines" div
          "/../../following-sibling::tr//td[contains(text(), 'Source')]" +             # Back up, drop down a row, find the "Source" cell
          "/../following-sibling::tr/td/div/input[contains(@src, 'add1.gif')]"         # Back up, drop down a row, find the "add" button
  #retries = 3
  #while true
    kaikifs.click_and_wait :xpath, xpath

    # NEED SOME STUFF TO DOUBLE CHECK THAT IT WAS ADDED. POSSIBLE ERRORS
    # "4 error(s) found on page" or "2 error(s) found on page"
    # * Chart was not selected ("Chart Code (Chart) is a required field.")
    # * Chart AZ was selected  ("The specified Account Number does not exist.")
    # Also, take screenshot? record errors?
  #  break unless kaikifs.is_text_present("error(s) found on page")
  #  retries -= 1
  #  if retries < 0
  #    kaikifs.log.error "The #{ordinal} item's new Source Lines didn't add so well. No more retries."
  #    false.should == true  # break out of the scenario?
  #    break  # did i not break out of the scenario?
  #  else
  #    kaikifs.log.warn "The #{ordinal} item's new Source Lines didn't add so well. Trying again..."
  #  end
  #end
end

# WD
When /^I set the first Vendor Address as the campus default for "([^"]*)"$/ do |value|
  kaikifs.set_field("document.newMaintainableObject.add.vendorAddresses[0].vendorDefaultAddresses.vendorCampusCode", value)
  kaikifs.record['current_vendor_address'] = 'vendorAddresses[0]'
end

# WD
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

# WD
# First written for Contract Manager Assignment
# Reeeeeeefactor
When /^I fill out the following for that "([^"]*)":$/ do |identifier, table|
  fields = table.rows_hash
  id_value = kaikifs.record[identifier]
  header_text = case identifier
    when "Requisition #" then "Requisition Number"
    else                      identifier
    end
  header_xpath = "//div[@id='workarea']//th[contains(text(), '#{header_text}')]"
  header_xpath = kaikifs.get_xpath(:xpath, header_xpath)
  # This will look something like:  id("tab-assignacontractmanager-div")/div[2]/table[1]/tbody[1]/tr[1]/th[2]
  # So lets take of the digits in the last brackets.
  column = ''
  if header_xpath =~ /(\[\d+\])$/
    column = $1
  end
  id_value_xpath = header_xpath + "/../following-sibling::tr/td#{column}"
  fields_xpath = nil
  if kaikifs.find_element(:xpath, id_value_xpath+"[contains(text(), '#{id_value}')]", :no_raise => true)
    fields_xpath = id_value_xpath+"[contains(text(), '#{id_value}')]/../td"
  elsif kaikifs.find_element(:xpath, id_value_xpath+"//*[contains(text(), '#{id_value}')]")
    fields_xpath = id_value_xpath+"//*[contains(text(), '#{id_value}')]/ancestor::tr/td"
  end

  # Now fields_xpath contains the xpath for all of the cells in the appropriate row. Now for each field, we find the appropriate column, and set the value!
  fields.each do |key, value|
    key_xpath = "//div[@id='workarea']//th[contains(text(), '#{key}')]"
    key_xpath = kaikifs.get_xpath(:xpath, key_xpath)
    if key_xpath =~ /(\[\d+\])$/
      field_column = $1
      field_xpath = fields_xpath + field_column + "//input[1]"
      kaikifs.set_field(field_xpath, value)
    else
      raise StandardError
    end
  end
end

# WD
When /^I fill out the ([0-9a-z]+) Item's "([^"]*)" with the following new Source Line:$/ do |ordinal, tab, table|
  numeral = EnglishNumbers::ORDINAL_TO_NUMERAL[ordinal]
  xpath = "//td[contains(text(), 'Item #{numeral}')]" +                      # The cell that contains only "Item 1"
          "/../following-sibling::tr//div[contains(text()[2], '#{tab}')]" +  # Back up, drop down a row, find the "Acounting Lines" div
          "/../../following-sibling::tr//td[contains(text(), 'Source')]" +   # Back up, drop down a row, find the "Source" cell
          "/../following-sibling::tr/th[contains(text(), '%s')]" +           # Back up, drop down a row, find the "Chart" header
          "/../following-sibling::tr/td//%s[contains(@title, '%s')]"         # Back up, drop down a row, find the "Chart" select
  fields = table.rows_hash

  retries = 3
  while true
    fields.each do |key, value|
      kaikifs.set_approximate_field(
        ApproximationsFactory::build(
          xpath,
          [key],
          ['select[1]', 'input[1]'],
          [key]
        ),
      value)
    end

    # NEED SOME STUFF TO DOUBLE CHECK THAT ITS ALL FILLED OUT.
    break unless (kaikifs.is_text_present("account not found") or  # Chart 'AZ' was selected
                  kaikifs.is_text_present("chart code is empty"))  # No Chart was selected
    retries -= 1
    if retries < 0
      kaikifs.log.error "The #{ordinal} item's new Source Lines didn't fill out so well. No more retries."
      false.should == true  # break out of the scenario?
      break  # did i not break out of the scenario?
    else
      kaikifs.log.warn "The #{ordinal} item's new Source Lines didn't fill out so well. Trying again..."
    end
  end

  #fields.each do |key, value|
  #  kaikifs.set_approximate_field(
  #    ApproximationsFactory::build(
  #      xpath,
  #      [key],
  #      ['select[1]', 'input[1]'],
  #      [key]
  #    ),
  #  value)
  #end
end

# WD
When /^I set the ([0-9a-z]+) Item's "([^"]*)" to "([^"]*)"/ do |ordinal, field, value|
  numeral = EnglishNumbers::ORDINAL_TO_NUMERAL[ordinal]
  title = case field
    when "Qty Invoiced"  then "Quantity Invoiced"
    when "Extended Cost" then "Extended Price"                # Facepalm
    when "Qty Received"  then "Item Received Total Quantity"  # Facepalm
    else                      field
    end
  xpath = "//th[contains(text(), '%s')]" +                                       # The table that contains the Line Items
          "/../th[contains(text()%s, '#{field}')]" +                             # Back up, find the label
          "/../following-sibling::tr/td[1]/b[contains(text(), '#{numeral}')]" +  # Back up, find the nth row
          "/../following-sibling::td//%s[contains(@title, '#{title}')]"       # Back up, find the input
  kaikifs.set_approximate_field(
    ApproximationsFactory.transpose_build(
      xpath,
      ['Item Line #', '',       'select'],
      ['Line #',      '[1]',    'input'],
      [nil,           '[2]',    nil]
    ),
    value
  )
end

Transform /#\{\d+i\}/ do |v|
  v.gsub(/#\{(\d+)i\}/) do |m|
    m =~ /(\d+)/
    d = $1.to_i-1
    (rand*(9*10**d) + 10**d).to_i
  end
end

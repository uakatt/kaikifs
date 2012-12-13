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

# WD
When /^I fill out a new (?:Vendor Address|vendorAddress) with default foreign values$/ do
  prefix = "document.newMaintainableObject.add.vendorAddresses."
  kaikifs.set_field(prefix+'vendorAddressTypeCode', 'PURCHASE ORDER')
  kaikifs.set_field(prefix+'vendorLine1Address', '123 main St.')
  kaikifs.set_field(prefix+'vendorCityName', 'Berlin')
  kaikifs.set_field(prefix+'vendorZipCode', '85719')
  kaikifs.set_field(prefix+'vendorCountryCode', 'GERMANY')
  kaikifs.set_field(prefix+'vendorDefaultAddressIndicator', 'Yes')
end

# WD
When /^I fill out a new (?:Vendor Address|vendorAddress) with the following:$/ do |table|
  fields = table.rows_hash
  prefix = "document.newMaintainableObject.add.vendorAddresses."
  fields.each do |key, value|
    kaikifs.set_field(prefix+key, value)
  end
end

# WD
When /^I fill out a new Contact with default values$/ do
  prefix = "document.newMaintainableObject.add.vendorContacts."
  kaikifs.set_field(prefix+'vendorContactName',                      'Samuel Smith')
  kaikifs.set_field(prefix+'vendorContactEmailAddress',              'samuel.smith@beer.com')
  kaikifs.set_field(prefix+'vendorLine1Address',                     '123 Main St.')
  kaikifs.set_field(prefix+'vendorCityName',                         'Berlin')
  kaikifs.set_field(prefix+'vendorStateCode',                        '--')
  kaikifs.set_field(prefix+'vendorZipCode',                          '12345-6789')
  kaikifs.set_field(prefix+'vendorCountryCode',                      'UNITED STATES')
  kaikifs.set_field(prefix+'vendorAddressInternationalProvinceName', 'Berlin')
  kaikifs.set_field(prefix+'vendorAttentionName',                    'Sammy')
  kaikifs.set_field(prefix+'vendorContactCommentText',               'Commenty comment')
end

# WD
When /^I fill out a new Vendor Shipping Special Conditions with default values$/ do
  prefix = "document.newMaintainableObject.add.vendorShippingSpecialConditions."
  kaikifs.set_field(prefix+'vendorShippingSpecialConditionCode',                      'LIVE ANIMAL')
end

# WD
When /^I fill out a new Vendor (.*) with default values, and the following:$/ do |tab, table|
  tabs_fields = {
    'Contact' => {
      'Contact Type' => 'ACCOUNTS RECEIVABLE',
      'Name'         => 'Samuel Smith',
      'Email Address' => 'samuel.smith@beer.com',
      'Address 1'     => '123 Main St.',
      'City'          => 'Berlin',
      'State'         => '--',
      'Postal Code'   => '12345-6789',
      'Province'      => 'Berlin',
      'Attention'     => 'Sammy',
      'Comments'      => 'Commenty comment comment'
    }
  }
  # largely borrowed from When /^I set a new ([^']*)'s "([^"]*)" to "([^"]*)"$/ in form_steps.rb
  div = tab_id_for(tab)

  #fields = table.rows_hash
  fields = tabs_fields[tab].merge table.rows_hash
  fields.each do |field, value|
    #kaikifs.set_field(prefix+key, value)
    kaikifs.set_approximate_field(
      ApproximationsFactory.transpose_build(
        "//div[@id='#{div}']//%s[contains(text()%s, '#{field}')]/../following-sibling::td/%s",
        ['th/label',    '',       'select[1]'],
        ['th/div',      '[1]',    'input[1]'],
        [nil,           '[2]',    'textarea[1]']
      ) +
      ApproximationsFactory.transpose_build(
        "//div[@id='#{div}']//th[contains(text()%s, '#{field}')]/../following-sibling::tr/td/div/%s[contains(@title, '#{field}')]",
        ['',       'select'],
        ['[1]',    'input'],
        ['[2]',    nil]
      ),
      value
    )
    #puts "#{field} set to \"#{value}\""
    put_fv_as_row(fields, field)
  end
end

def put_fv_as_row(fields, field)
  max_ksize =   fields.keys.map(&:size).max
  max_vsize = fields.values.map(&:size).max
  puts "| %#{max_ksize}s | %#{max_vsize}s |" % [field, fields[field]]
end

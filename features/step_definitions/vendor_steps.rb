TabsFields = {
  'Address' => {
    'Address Type'           => 'PURCHASE ORDER',
    'Address 1'              => '123 Main St.',
    'City'                   => 'Tucson',
    'State'                  => 'AZ',
    'Postal Code'            => '85719',
    'Country'                => 'UNITED STATES',
    'Set as Default Address' => 'Yes'
  },
  'Address (Foreign)' => {
    'Address Type'           => 'PURCHASE ORDER',
    'Address 1'              => '123 Main St.',
    'City'                   => 'Berlin',
    'Postal Code'            => '12345-6789',
    'Country'                => 'GERMANY',
    'Set as Default Address' => 'Yes'
  },
  'Contact' => {
    'Contact Type'  => 'ACCOUNTS RECEIVABLE',
    'Name'          => 'Samuel Smith',
    'Email Address' => 'samuel.smith@beer.com',
    'Address 1'     => '123 Main St.',
    'City'          => 'Berlin',
    'State'         => '--',
    'Postal Code'   => '12345-6789',
    'Province'      => 'Berlin',
    'Attention'     => 'Sammy',
    'Comments'      => 'Commenty comment comment'
  },
  'Shipping Special Conditions' => {
    'Shipping Special Condition' => 'LIVE ANIMAL'
  }
}

# WD
#When /^I fill out a new (?:Vendor Address|vendorAddress) with default values$/ do
#  prefix = "document.newMaintainableObject.add.vendorAddresses."
#  kaikifs.set_field(prefix+'vendorAddressTypeCode', 'PURCHASE ORDER')
#  kaikifs.set_field(prefix+'vendorLine1Address', '123 main St.')
#  kaikifs.set_field(prefix+'vendorCityName', 'Tucson')
#  kaikifs.set_field(prefix+'vendorStateCode', 'AZ')
#  kaikifs.set_field(prefix+'vendorZipCode', '85719')
#  kaikifs.set_field(prefix+'vendorCountryCode', 'UNITED STATES')
#  kaikifs.set_field(prefix+'vendorDefaultAddressIndicator', 'Yes')
#end

# WD
#When /^I fill out a new (?:Vendor Address|vendorAddress) with default foreign values$/ do
#  prefix = "document.newMaintainableObject.add.vendorAddresses."
#  kaikifs.set_field(prefix+'vendorAddressTypeCode', 'PURCHASE ORDER')
#  kaikifs.set_field(prefix+'vendorLine1Address', '123 main St.')
#  kaikifs.set_field(prefix+'vendorCityName', 'Berlin')
#  kaikifs.set_field(prefix+'vendorZipCode', '85719')
#  kaikifs.set_field(prefix+'vendorCountryCode', 'GERMANY')
#  kaikifs.set_field(prefix+'vendorDefaultAddressIndicator', 'Yes')
#end

# WD
When /^I fill out a new (?:Vendor Address|vendorAddress) with the following:$/ do |table|
  fields = table.rows_hash
  prefix = "document.newMaintainableObject.add.vendorAddresses."
  fields.each do |key, value|
    kaikifs.set_field(prefix+key, value)
  end
end

# WD
When /^I fill out a new Vendor (.*) with default values$/ do |tab|
  # largely borrowed from When /^I set a new ([^']*)'s "([^"]*)" to "([^"]*)"$/ in form_steps.rb
  fields = TabsFields[tab]
  tab = case tab
        when 'Address (Foreign)' then 'Address'
        else                           tab
        end
  div = tab_id_for(tab)
  put_table_title(fields, tab)
  fields.each do |field, value|
    kaikifs.set_approximate_field(
      approximations_for_field_inside_div(field, div),
      value
    )
    put_fv_as_row(fields, field)
  end
end

# WD
When /^I fill out a new Vendor (.*) with default values, and the following:$/ do |tab, table|
  # largely borrowed from When /^I set a new ([^']*)'s "([^"]*)" to "([^"]*)"$/ in form_steps.rb
  div = tab_id_for(tab)

  fields = TabsFields[tab].merge table.rows_hash
  put_table_title(fields, tab)
  fields.each do |field, value|
    kaikifs.set_approximate_field(
      approximations_for_field_inside_div(field, div),
      value
    )
    put_fv_as_row(fields, field) unless table.rows_hash.keys.include?(field)
  end
end

def approximations_for_field_inside_div(field, div)
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
  )
end

def put_fv_as_row(fields, field)
  max_ksize =   fields.keys.map(&:size).max
  max_vsize = fields.values.map(&:size).max
  puts "| %#{max_ksize}s | %#{max_vsize}s |" % [field, fields[field]]
end

def put_table_title(fields, tab)
  max_ksize =   fields.keys.map(&:size).max
  max_vsize = fields.values.map(&:size).max
  puts "| #{tab.center(max_ksize + max_vsize + 3)} |"
end

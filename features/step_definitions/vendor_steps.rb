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

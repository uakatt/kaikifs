When /^I record this document number$/ do
  doc_nbr = kaikifs.get_text("xpath=//th[contains(text(), 'Doc Nbr')]/following-sibling::td").strip
  kaikifs.record[:document_number] = doc_nbr
  puts doc_nbr
end

When /^I record this "([^"]*)"$/ do |field|
  value = kaikifs.get_text("xpath=//th[contains(text(), 'Vendor Name')]/following-sibling::*").strip
  kaikifs.record[field] = value.strip
  puts "#{field} = #{value}"
end

When /^I set the "([^"]*)" to that one$/ do |field|
  value = kaikifs.record[field]
  kaikifs.set_approximate_field(
    [
      "//th/label[contains(text(), '#{field}:')]/../following-sibling::*/input[1] | //th/label[contains(text(), '#{field}:')]/../following-sibling::*/select[1]",
      "//th[contains(text(), '#{field}')]",
      "//th[contains(text()[1], '#{field}')]",
      "//th[contains(text()[2], '#{field}')]/../following-sibling::*//*[contains(@title, '#{field}')]", # Group > create new > Chart Code
      "//th[contains(text()[3], '#{field}')]"
    ],
    value)
end

When /^I save a screenshot as "([^"]*)"$/ do |name|
  kaikifs.screenshot(name.file_safe + '_' + Time.now.strftime("%Y%m%d%H%M%S"))
end

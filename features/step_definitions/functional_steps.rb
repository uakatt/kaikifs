When /^I record this document number$/ do
  doc_nbr = kaikifs.find_element(:xpath, "//th[contains(text(), 'Doc Nbr')]/following-sibling::td").text.strip
  kaikifs.record[:document_number] = doc_nbr
  puts doc_nbr
end

When /^I record this "([^"]*)"$/ do |field|
  value = kaikifs.find_element(:xpath, "//th[contains(text(), '#{field}')]/following-sibling::*").text.strip
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

# Highlights a button based on its name
When /^I highlight the "([^"]*)" submit button$/ do |action|
    kaikifs.highlight :name, "methodToCall.#{action.gsub(/ /, '').camelize(:lower)}"
end

When /^I scroll to the image with alt text "([^"]*)"$/ do |text|
  kaikifs.find_element(:xpath, "//*[@alt='#{text}']").location_once_scrolled_into_view
end

When /^I enlargen "([^"]*)"$/ do |text|
  kaikifs.enlargen :xpath, "//*[contains(text(), '#{text}')]"
end

When /^I requeue all of the documents$/ do
  kaikifs.record[:document_numbers].each do |document|
    kaikifs.record[:document_number] = document
    steps %{
    And I set the "Document ID" to the given document number
    And I click "get document"
    And I highlight the "Queue Document Requeuer" submit button
    And I sleep for "2" seconds
    And I click the "Queue Document Requeuer" submit button
    And I scroll to the image with alt text "Workflow"
    Then I should see "Document Requeuer was successfully scheduled"
    And I enlargen "Document Requeuer was successfully scheduled"
    And I sleep for "5" seconds
    }
  end
end

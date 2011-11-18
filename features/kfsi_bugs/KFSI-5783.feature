Feature: KFSI-5783

  Background:
    Given I am up top

  @jira
  Scenario:

    Given I am logged in
    And I am on the "main_menu" tab
    When I click the "Requisition" portal link
    And I set the "Description" to something like "testing: KFSI-5783"
    And I check "Receiving Required"
    And I start a lookup for "Building"
    And I set the "Building Code" to "10"
    And I click "search"
    And I return with the first result
    And I start a lookup for "Room"
    And I set the "Building Room Number" to "0001"
    And I click "search"
    And I return with the first result
    And I start a lookup for "Suggested Vendor"
    And I set the "Vendor Name" to "Micron"
    And I click "search"
    And I return with the first result
    #And I fill out a new Item with default values
    And I set a new Item's "Item Type" to "QUANTITY TAXABLE"
    And I set a new Item's "Quantity" to "10"
    And I set a new Item's "UOM" to "ea"
    And I set a new Item's "Description" to "a 5783 widget"
    And I set a new Item's "Unit Cost" to "100"
    And I add that "Item"
    And I show the first Item's "Accounting Lines"
    And I fill out the first Item's "Accounting Lines" with the following new Source Line:
      | Chart          | UA      |
      | Account Number | 1080000 |
      | Object         | 5230    |
      | Percent        | 100     |
    And I add that first Item's new Source Line

    And I set a new Item's "Item Type" to "QUANTITY TAXABLE"
    And I set a new Item's "Quantity" to "20"
    And I set a new Item's "UOM" to "ea"
    And I set a new Item's "Description" to "another 5783 widget"
    And I set a new Item's "Unit Cost" to "200"
    And I add that "Item"
    And I show the second Item's "Accounting Lines"
    And I fill out the second Item's "Accounting Lines" with the following new Source Line:
      | Chart          | UA      |
      | Account Number | 1080000 |
      | Object         | 5230    |
      | Percent        | 100     |
    And I add that second Item's new Source Line

    And I set a new Item's "Item Type" to "QUANTITY TAXABLE"
    And I set a new Item's "Quantity" to "30"
    And I set a new Item's "UOM" to "ea"
    And I set a new Item's "Description" to "a third 5783 widget"
    And I set a new Item's "Unit Cost" to "300"
    And I add that "Item"
    And I show the third Item's "Accounting Lines"
    And I fill out the third Item's "Accounting Lines" with the following new Source Line:
      | Chart          | UA      |
      | Account Number | 1080000 |
      | Object         | 5230    |
      | Percent        | 100     |
    And I add that third Item's new Source Line

    And I set the "Requestor Email" to "kfsi-5783@email.arizona.edu" if blank
    And I click "calculate"
    And I click "submit"
    Then I should see "Document was successfully submitted."

    When I record this document number
    When I record this "Requisition #"
    And I backdoor as "kdenman"
    And I open my Action List to the last page
    And I pause
    And I open that document
    And I click "approve"
    Then I should see my Action List

    When I backdoor as "kfs-test-sec22"
    And I open my Action List to the last page
    And I pause
    And I open that document
    And I click "approve"
    Then I should see my Action List

    When I backdoor as "kfs-test-sec40"
    And I am on the "main_menu" tab
    And I pause
    And I click the "Contract Manager Assignment" portal link
    And I fill out the following for that "Requisition #":
      | Contract Manager | 10 |
    And I click "submit"


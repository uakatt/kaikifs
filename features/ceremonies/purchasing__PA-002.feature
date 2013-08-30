Feature: Purchasing PA-001

  Background:
    Given I am up top

  Scenario:

    Given I am logged in
    And I am on the "main_menu" tab
    When I click the "Requisition" portal link
    And I set the "Description" to something like "testing: PA-001"
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
    And I save a screenshot as "Requisition Doc"
    And I backdoor as the fiscal officer
    And I open my Action List, refreshing until that document appears
    And I pause
    And I open that document
    And I click "approve"
    Then I should see my Action List

    When I backdoor as the UA FSO FM Team 451
    And I open my Action List, refreshing until that document appears
    And I pause
    And I open that document
    And I click "approve"
    Then I should see my Action List

    When I log in as a UA PACS Buyer
    And I am on the "main_menu" tab
    And I pause
    And I click the "Contract Manager Assignment" portal link
    And I fill out the following for that "Requisition #":
      | Contract Manager | 10 |
    And I click "submit"


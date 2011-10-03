Feature: KFSI-1021

  Background:
    Given I am up top

  @jira
  Scenario: A requisition against a new vendor routes OK.

    Given I am backdoored as "kfs-test-sec32"
    And I am on the "main_menu" tab
    And I am fast
    When I click the "Vendor" portal link
    And I click "create new"
    And I set "documentDescription" in the "documentHeader" to something like "testing: KFSI-1021"
    And I set the new "vendorName" to "KFSI-1021 #{4i}"
    And I set the new "vendorHeader.vendorTypeCode" to "Purchase Order"
    And I set the new "vendorHeader.vendorTaxNumber" to "00#{5i}00"
    And I set the new "vendorHeader.vendorTaxTypeCode" radio to "SSN"
    And I set the new "vendorHeader.vendorOwnershipCode" to "INDIVIDUAL/SOLE PROPRIETOR"
    And I set the new "extension.conflictOfInterest" to "None"
    And I set the new "extension.defaultB2BPaymentMethodCode" to "A - ACH/Check"
    And I fill out a new vendorAddress with default values
    And I add that vendorAddress and wait
    And I set the first vendorAddress's additional vendorDefaultAddress's "vendorCampusCode" to "MC - Main Campus"
    And I add that first vendorAddress's vendorDefaultAddress and wait
    And I click "route" and wait
    And I click "yes" and wait
    Then I should see "Document was successfully submitted."
    When I record this document number
    And I record this "Vendor Name"
    And I am up top
    And I backdoor as "kfs-test-sec50"
    And I open my Action List
    And I open that document
    And I click "approve" and wait
    And I click "yes" and wait
    And I am on the "main_menu" tab
    And I click the "Requisition" portal link
    And I set "documentDescription" in the "documentHeader" to something like "testing: KFSI-1021"
    And I start a lookup for "Building"
    #And i start a search for "Building" under "Delivery" ?
    And I set "buildingCode" to "10"
    And I click "search" and wait
    And I return with the first result
    And I start a lookup for "Room"
    #And i start a search for "Room" under "Delivery" ?
    And I set "buildingRoomNumber" to "0001"
    And I click "search" and wait
    And I return with the first result
    And I start a lookup for "Suggested Vendor"
    #And I start a lookup for "Suggested Vendor" under "Vendor" ?
    And I set the "Vendor Name" to that one
    And I click "search" and wait
    And I return with the first result
    And I fill out a new purchasingItemLine with default values
    And I add that purchasingItemLine and wait
    And I click "calculate" and wait
    And I click "route" and wait
    Then I should see "Document was successfully submitted."


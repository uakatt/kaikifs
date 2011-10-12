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
    And I set the "Description" to something like "testing: KFSI-1021"
    And I set the new "Vendor Name" to "KFSI-1021 #{4i}"
    And I set the new "Vendor Type" to "Purchase Order"
    And I set the new "Tax Number" to "99#{5i}99"
    And I set the new "Tax Number Type" radio to "SSN"
    And I set the new "Ownership Type" to "INDIVIDUAL/SOLE PROPRIETOR"
    And I set the new "Conflict of Interest" to "None"
    And I set the new "Default Payment Method" to "A - ACH/Check"
    And I fill out a new Vendor Address with default values
    And I add that "Vendor Address" and wait
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I click "route" and wait
    And I click "yes" and wait
    Then I should see "Document was successfully submitted."
    When I record this document number
    And I record this "Vendor Name"
    And I am up top
    And I backdoor as "kfs-test-sec50"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I click "approve" and wait
    And I click "yes" and wait
    And I am on the "main_menu" tab
    And I click the "Requisition" portal link
    And I set "documentDescription" in the "documentHeader" to something like "testing: KFSI-1021"
    And I start a lookup for "Building"
    And I set "buildingCode" to "10"
    And I click "search" and wait
    And I return with the first result
    And I start a lookup for "Room"
    And I set "buildingRoomNumber" to "0001"
    And I click "search" and wait
    And I return with the first result
    And I start a lookup for "Suggested Vendor"
    And I set the "Vendor Name" to that one
    And I click "search" and wait
    And I return with the first result
    And I fill out a new Item with default values
    And I add that "Item" and wait
    And I sleep for "10" seconds
    And I set the "Requestor Phone" to "345-876-6589"
    And I set the "Requestor Email" to "kfs-test-sec19@email.arizona.edu"
    And I click "calculate" and wait
    And I click "route" and wait
    Then I should see "Document was successfully submitted."


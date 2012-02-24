Feature: KFSI-1021

  Background:
    Given I am up top

  @jira
  Scenario: A requisition against a new vendor routes OK.

    Given I am backdoored as "kfs-test-sec32"
    And I am on the "main_menu" tab
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
    And I add that "Vendor Address"
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I show the "Supplier Diversity" tab
    And I set the new "Supplier Diversity" to "AZ SMALL BUSINESS"
    And I add that "Supplier Diversity"
    And I click "submit"
    And I click "yes"
    Then I should see the message "Document was successfully submitted."
    When I record this document number
    And I record this "Vendor Name"
    And I am up top
    And I backdoor as "kfs-test-sec50"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I click "approve"
    And I click "yes"
    And I am on the "main_menu" tab
    And I click the "Requisition" portal link
    And I set the "Description" to something like "testing: KFSI-1021"
    And I start a lookup for "Building"
    And I set the "Building Code" to "10"
    And I click "search"
    And I return with the first result
    And I start a lookup for "Room"
    And I set the "Building Room Number" to "0001"
    And I click "search"
    And I return with the first result
    And I start a lookup for "Suggested Vendor"
    And I set the "Vendor Name" to that one
    And I click "search"
    And I return with the first result
    And I fill out a new Item with default values
    And I add that "Item"
    And I set the "Requestor Phone" to "345-876-6589"
    And I set the "Requestor Email" to "kfs-test-sec19@email.arizona.edu"
    And I click "calculate"
    And I click "submit"
    Then I should see "Document was successfully submitted."


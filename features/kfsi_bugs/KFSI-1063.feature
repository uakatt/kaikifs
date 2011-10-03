Feature: KFSI-1063

  Background:
    Given I am up top

  @jira @incomplete
  Scenario: I can hide inactive Vendor Aliases.

    Given I am backdoored as "kfs-test-sec32"
    And I am on the "main_menu" tab
    And I am fast
    When I click the "Vendor" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: KFSI-1063"
    And I set the new "Vendor Name" to "KFSI-1063 #{4i}"
    And I set the new "Vendor Type" to "Purchase Order"
    And I set the new "Tax Number" to "00#{5i}00"
    And I set the new "Tax Number Type" radio to "SSN"
    And I set the new "Ownership Type" to "INDIVIDUAL/SOLE PROPRIETOR"
    And I set the new "Conflict of Interest" to "None"
    And I sleep for "10" seconds
    And I set the new "Default Payment Method" to "A - ACH/Check"
    And I fill out a new Vendor Address with default values
    And I add that "Vendor Address" and wait
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that first Vendor Address's New Default Address and wait
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
    And I backdoor as "kfs-test-sec32"
    And I am on the "main_menu" tab
    And I click the "Vendor" portal link
    And I set the "Vendor Name" to that one
    And I click "search" and wait
    And I edit the first one
    And I click "hide inactive" under Search Alias
    Then I should see "Document was successfully submitted."


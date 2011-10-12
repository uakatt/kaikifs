Feature: KFSI-4479

  Background:
    Given I am up top

  @jira @golive_blocker
  Scenario: AZ Tax # can be entered correctly

    Given I am backdoored as "kfs-test-sec32"
    And I am on the "main_menu" tab
    When I click the "Vendor" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: KFSI-4479"
    And I set the new "Vendor Name" to "KFSI-4479 #{4i}"
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
    And I set the new "Arizona Sales Tax License Number" to "123456789AB"
    And I click "route" and wait
    And I click "yes" and wait
    Then I should see "Document was successfully submitted."
    And I should see "123456789AB"
    When I record this document number
    And I am up top
    And I backdoor as "kfs-test-sec50"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I click "disapprove" with reason "Don't leave a doc hanging." and wait

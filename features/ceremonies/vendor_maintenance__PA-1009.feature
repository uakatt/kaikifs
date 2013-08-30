Feature: Vendor Maintenance

  Background:
    Given I am up top

  Scenario: PA-1009-01-04-CreateForeignVendor

    Given I am logged in as "kfs-test-sec32"
    And I am on the "main_menu" tab
    When I click the "Vendor" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: PA-1009"
    And I set the new "Vendor Name" to "PA-1009 #{4i}"
    And I set the new "Vendor Type" to "Purchase Order"
    And I set the new "Is this a foreign vendor" to "Yes"
    And I set the new "Tax Number" to "99#{5i}99"
    And I set the new "Tax Number Type" radio to "SSN"
    And I set the new "Ownership Type" to "FOREIGN VENDOR/INDIVIDUAL"
    And I set the new "Ownership Type Category" to "FOREIGN COMPANY"
    And I set the new "Conflict of Interest" to "None"
    And I set the new "Default Payment Method" to "A - ACH/Check"
    And I fill out a new Vendor Address (Foreign) with default values
    And I add that "Vendor Address"
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I show the "Supplier Diversity" tab
    And I set the new "Supplier Diversity" to "AZ SMALL BUSINESS"
    And I add that "Supplier Diversity"
    And I set the new "Arizona Sales Tax License Number" to "123456789AB"
    And I click "submit"
    And I click "yes"
    Then I should see "Document was successfully submitted."
    And I should see "ID:" in the "routeLog" iframe
    And  I should see "Actions Taken" in the "routeLog" iframe
    When I record this document number
    And I save a screenshot as "Vendor Doc"
    And I log in as "kfs-test-sec50"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I click "approve"

  Scenario: PA-1009-01-04-CreateForeignVendor, more exciting fields

    Given I am logged in as "kfs-test-sec32"
    And I am on the "main_menu" tab
    When I click the "Vendor" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: PA-1009"
    And I set the new "Vendor Name" to "PA-1009 #{4i}"
    And I set the new "Vendor Type" to "Purchase Order"
    And I set the new "Is this a foreign vendor" to "Yes"
    And I set the new "Tax Number" to "99#{5i}99"
    And I set the new "Tax Number Type" radio to "SSN"
    And I set the new "Ownership Type" to "FOREIGN VENDOR/INDIVIDUAL"
    And I set the new "Ownership Type Category" to "FOREIGN COMPANY"
    And I set the new "Conflict of Interest" to "None"
    And I set the new "Default Payment Method" to "A - ACH/Check"
    And I fill out a new Vendor Address (Foreign) with default values
    And I add that "Vendor Address"
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait

    And I show the "Contact" tab
    And I fill out a new Vendor Contact with default values, and the following:
      | Attention        | Not Sammy  |
      | Comments         | Overridden |
    And I add that "Contact"

    And I show the "Supplier Diversity" tab
    And I set the new "Supplier Diversity" to "AZ SMALL BUSINESS"
    And I add that "Supplier Diversity"

    And I show the "Shipping Special Conditions" tab
    And I fill out a new Vendor Shipping Special Conditions with default values
    And I add that "Shipping Special Conditions"

    And I set the new "Arizona Sales Tax License Number" to "123456789AB"
    And I click "submit"
    And I click "yes"

    Then I should see "Document was successfully submitted."
    And I should see "ID:" in the "routeLog" iframe
    And  I should see "Actions Taken" in the "routeLog" iframe
    When I record this document number
    And I save a screenshot as "Vendor Doc"
    And I log in as "kfs-test-sec50"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I click "approve"
    And I click "yes"

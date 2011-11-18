@cucumber_example
Feature: KFSI-4479

  Background:
    Given I am up top

  Scenario: AZ Tax # can be entered correctly
    I want to write a very verbose scenario
    Where I specify every field, ever.

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
    And I set a new Address's "Address Type" to "PURCHASE ORDER"
    And I set a new Address's "Address 1" to "123 Main St."
    And I set a new Address's "City" to "Tucson"
    And I set a new Address's "State" to "AZ"
    And I set a new Address's "Postal Code" to "85719"
    And I set a new Address's "Country" to "UNITED STATES"
    And I set a new Address's "Set as Default Address" to "Yes"
    And I add that "Vendor Address"
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I set the new "Arizona Sales Tax License Number" to "123456789AB"
    And I click "submit"
    And I click "yes"
    Then I should see "Document was successfully submitted."
    And I should see "123456789AB"

  Scenario: AZ Tax # can be entered correctly
    I want to write a cleaner scenario
    Where field names and values are tabulated.

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
    And I fill out a new vendorAddress with the following:
      | vendorAddressTypeCode         | PURCHASE ORDER |
      | vendorLine1Address            | 123 Main St.   |
      | vendorCityName                | Tucson         |
      | vendorStateCode               | AZ             |
      | vendorZipCode                 | 85719          |
      | vendorCountryCode             | UNITED STATES  |
      | vendorDefaultAddressIndicator | Yes            |
    And I add that "Vendor Address"
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I set the new "Arizona Sales Tax License Number" to "123456789AB"
    And I click "submit"
    And I click "yes"
    Then I should see "Document was successfully submitted."
    And I should see "123456789AB"

  Scenario: AZ Tax # can be entered correctly
    I want to write a quick scenario
    Where I use default values.

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
    And I add that "Vendor Address"
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I set the new "Arizona Sales Tax License Number" to "123456789AB"
    And I click "submit"
    And I click "yes"
    Then I should see "Document was successfully submitted."
    And I should see "123456789AB"


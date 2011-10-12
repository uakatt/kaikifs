Feature: KFSI-5730

  Background:
    Given I am up top

  @jira @blocker
  Scenario: A PO vendor can be created.

    Given I am logged in
    And I am on the "main_menu" tab
    And I am fast
    When I click the "Vendor" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: KFSI-5730"
    And I set the new "Vendor Name" to "KFSI-5730 #{4i}"
    And I set the new "Vendor Type" to "Purchase Order"
    And I set the new "Tax Number" to "99#{5i}99"
    And I set the new "Tax Number Type" radio to "SSN"
    And I set the new "Ownership Type" to "INDIVIDUAL/SOLE PROPRIETOR"
    And I set the new "Conflict of Interest" to "None"
    And I set the new "Default Payment Method" to "A - ACH/Check"
    And I fill out a new Vendor Address with default values
    And I fill out a new Vendor Address with the following:
      | vendorAddressTypeCode         | PURCHASE ORDER |
      | vendorLine1Address            | 123 Main St.   |
      | vendorCityName                | Tucson         |
      | vendorStateCode               | AZ             |
      | vendorZipCode                 | 85719          |
      | vendorCountryCode             | UNITED STATES  |
      | vendorDefaultAddressIndicator | Yes            |
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I click "route" and wait
    And I click "yes" and wait
    Then I should see "Document was successfully submitted."
    When I record this document number
    And I am up top
    And I backdoor as "kfs-test-sec50"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I click "disapprove" with reason "Don't leave a doc hanging." and wait
    #Then?

  @jira @blocker
  Scenario: A DV vendor can be created.

    Given I am logged in
    And I am on the "main_menu" tab
    And I am fast
    When I click the "Vendor" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: KFSI-5730"
    And I set the new "Vendor Name" to "KFSI-5730 #{4i}"
    And I set the new "Vendor Type" to "Disbursement Voucher"
    And I set the new "Tax Number" to "99#{5i}99"
    And I set the new "Tax Number Type" radio to "SSN"
    And I set the new "Ownership Type" to "INDIVIDUAL/SOLE PROPRIETOR"
    And I set the new "Conflict of Interest" to "None"
    And I set the new "Default Payment Method" to "A - ACH/Check"
    And I fill out a new Vendor Address with default values
    And I fill out a new Vendor Address with the following:
      | vendorAddressTypeCode         | REMIT         |
      | vendorLine1Address            | 123 Main St.  |
      | vendorCityName                | Tucson        |
      | vendorStateCode               | AZ            |
      | vendorZipCode                 | 85719         |
      | vendorCountryCode             | UNITED STATES |
      | vendorDefaultAddressIndicator | Yes           |
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I click "route" and wait
    And I click "yes" and wait
    Then I should see "Document was successfully submitted."
    When I record this document number
    And I am up top
    And I backdoor as "kfs-test-sec50"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I click "disapprove" with reason "Don't leave a doc hanging." and wait
    #Then?

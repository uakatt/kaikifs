Feature: KFSI-5772

  Background:
    Given I am up top

  @jira @incomplete
  Scenario: Can save a note to an ENROUTE Vendor

    Given I am logged in
    And I am on the "main_menu" tab
    When I click the "Vendor" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: KFSI-5772"
    And I set the new "Vendor Name" to "KFSI-5772 #{4i}"
    And I set the new "Vendor Type" to "Disbursement Voucher"
    And I set the new "Tax Number" to "99#{5i}99"
    And I set the new "Tax Number Type" radio to "SSN"
    And I set the new "Ownership Type" to "INDIVIDUAL/SOLE PROPRIETOR"
    And I set the new "Conflict of Interest" to "None"
    And I set the new "Default Payment Method" to "A - ACH/Check"
    And I fill out a new Vendor Address with the following:
      | Address Type           | REMIT         |
      | Address 1              | 123 Main St.  |
      | City                   | Tucson        |
      | State                  | AZ            |
      | Postal Code            | 85719         |
      | Country                | UNITED STATES |
      | Set as Default Address | Yes           |
    And I add that "Vendor Address" and wait
    And I set the first Vendor Address as the campus default for "MC - Main Campus"
    And I add that Default Address and wait
    And I click "route" and wait
    And I click "yes" and wait
    Then I should see "Document was successfully submitted."
    When I record this document number
    And I record this "Vendor Name"
    And I am up top
    And I backdoor as "kfs-test-sec36"
    And I open my Action List, refreshing until that document appears
    And I open that document
    And I add a Note with the following:
      | Note Text        | This is a note. |
    And I show the "Ad Hoc Recipients" tab
    And I add a Person Request with the following:
      | Action Requested | APPROVE         |
      | Person           | kfs-test-sec1   |
    And I click "send ad hoc request" and wait
    And I sleep for "2" seconds
    And I click "reload" and wait
    Then I should see "AdHoc Requests have been sent."
    And I should see "This is a note."


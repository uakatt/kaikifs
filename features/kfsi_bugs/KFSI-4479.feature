Feature: Vendor Maintenance

  Background:
    Given I am up top

  Scenario: AZ Tax # can be entered correctly

    Given I am backdoored as "kfs-test-sec32"
    And I am on the "main_menu" tab
    When I click the "Vendor" portal link
    And I click "create new"
    And I set "documentDescription" in the "documentHeader" to something like "testing: KFSI-4479"
    And I set the new "vendorName" to "KFSI-4479 #{4i}"
    #And I set the new "vendorHeader.vendorTypeCode" to "PO"
    And I set the new "vendorHeader.vendorTypeCode" to "Purchase Order"
    And I set the new "vendorHeader.vendorTaxNumber" to "123456789"
    And I set the new "vendorHeader.vendorTaxTypeCode" radio to "SSN"
    And I set the new "vendorHeader.vendorOwnershipCode" to "INDIVIDUAL/SOLE PROPRIETOR"
    And I set the new "extension.conflictOfInterest" to "None"
    And I set the new "extension.defaultB2BPaymentMethodCode" to "A - ACH/Check"
    And I set an additional vendorAddress's "vendorAddressTypeCode" to "PURCHASE ORDER"
    And I set an additional vendorAddress's "vendorLine1Address" to "123 Main St."
    And I set an additional vendorAddress's "vendorCityName" to "Tucson"
    And I set an additional vendorAddress's "vendorStateCode" to "AZ"
    And I set an additional vendorAddress's "vendorZipCode" to "85719"
    And I set an additional vendorAddress's "vendorCountryCode" to "UNITED STATES"
    And I set an additional vendorAddress's "vendorDefaultAddressIndicator" to "Yes"
    And I add that vendorAddress and wait
    And I set the first vendorAddress's additional vendorDefaultAddress's "vendorCampusCode" to "MC - Main Campus"
    And I add that first vendorAddress's vendorDefaultAddress and wait
    And I set the new "extension.azSalesTaxLicense" to "123456789AB"
    And I click "route" and wait
    And I click "yes" and wait
    Then I should see "Document was successfully submitted."
    #And I should see "123456789AB" in "document.newMaintainableObject.extension.azSalesTaxLicense.div"
    And I should see "123456789AB"


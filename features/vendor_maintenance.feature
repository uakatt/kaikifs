Feature: Vendor Maintenance

  Background:
    Given I am up top

  Scenario: CFG001-PA-01
    Business Process is CFG001 - Cost Source
    Test Scenario is CFG001-PA-01

    Given I am backdoored as "kfs-test-sec32"
    And I am on the "maintenance" tab
    When I click the "Cost Source" portal link
    And I click "create new"
    And I set "documentDescription" in the "documentHeader" to something like "testing: CFG001-PA-01"
    And I hide the "DocumentOverview" tab
    And I set the new "purchaseOrderCostSourceCode" to "KA#{2i}"
    And I set the new "purchaseOrderCostSourceDescription" to "Kaiki"
    And I set the new "itemUnitPriceLowerVariancePercent" to "20"
    And I set the new "itemUnitPriceUpperVariancePercent" to "10"
    And I click "route" and wait
    And I show the "RouteLog" tab
    Then I should see "ID:" in the "routeLog" iframe
    And  I should see "Actions Taken" in the "routeLog" iframe

  Scenario: CFG003-PA04
    Business Process is CFG003 - Campus Parameter
    Test Scenario is CFG003-PA04

    Given I am backdoored as "kfs-test-sec32"
    And I am on the "maintenance" tab
    When I click the "Campus Parameter" portal link
    And I click "search" and wait
    And I click "edit" where "Campus Code" is "MC"
    And I set "documentDescription" in the "documentHeader" to "testing: CFG003-PA04"
    And I hide the "DocumentOverview" tab
    And I set the new "active" to "false"
    And I click "route" and wait
    Then I should see "Document was successfully submitted."
    When I show the "RouteLog" tab
    Then I should see "ID:" in the "routeLog" iframe
    And  I should see "Actions Taken" in the "routeLog" iframe
    # Untested: "The status should relected the proper state of the document such as saved, cancelled, final or enroute. The actions tab should list all of the actions taken on this document in chronological order."
    # Untested: Click Button: Route Log/Pending Action Requests (if tab is present)
    # Untested: This tab should display the individual that this document is routed to along with the appropriate action description
    # Untested: Click Button: Route Log/Future Action Requests
    # Untested: This tab should display the individual(s)  that this document is routed in addition to the pending route. The appropriate action description should appear.

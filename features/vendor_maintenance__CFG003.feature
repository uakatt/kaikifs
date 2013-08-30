Feature: Vendor Maintenance

  Background:
    Given I am up top

  @funky_test
  Scenario: CFG001-PA-01
    Business Process is CFG001 - Cost Source
    Test Scenario is CFG001-PA-01

    Given I am logged in as "kfs-test-sec47"
    And I am on the "maintenance" tab
    When I click the "Cost Source" portal link
    And I click "create new"
    And I set the "Description" to something like "testing: CFG001-PA-01"
    And I hide the "Document Overview" tab
    And I set the "Cost Source Code" to "KA#{2i}"
    And I set the "Cost Source Description" to "Kaiki"
    And I set the "Item Unit Price Lower Variance Percent" to "20"
    And I set the "Item Unit Price Upper Variance Percent" to "10"
    And I click "submit"
    And I show the "Route Log" tab
    Then I should see "ID:" in the "routeLog" iframe
    And  I should see "Actions Taken" in the "routeLog" iframe

  @funky_test
  Scenario: CFG003-PA04
    Business Process is CFG003 - Campus Parameter
    Test Scenario is CFG003-PA04

    Given I am backdoored as "kfs-test-sec47"
    And I am on the "maintenance" tab
    When I click the "Campus Parameter" portal link
    And I click "search"
    And I edit the "Main Campus" one
    And I set the "Description" to something like "testing: CFG001-PA-01"
    And I hide the "Document Overview" tab
    And I set the "Active Indicator" to "false"
    And I click "submit"
    Then I should see "Document was successfully submitted."
    When I show the "Route Log" tab
    Then I should see "ID:" in the "routeLog" iframe
    And  I should see "Actions Taken" in the "routeLog" iframe
    # Untested: "The status should relected the proper state of the document such as saved, cancelled, final or enroute. The actions tab should list all of the actions taken on this document in chronological order."
    # Untested: Click Button: Route Log/Pending Action Requests (if tab is present)
    # Untested: This tab should display the individual that this document is routed to along with the appropriate action description
    # Untested: Click Button: Route Log/Future Action Requests
    # Untested: This tab should display the individual(s)  that this document is routed in addition to the pending route. The appropriate action description should appear.

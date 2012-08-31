Feature: Pcard Maintenance

  Background:
    Given I am up top

  @funky_test
  Scenario: PA1003-01
    Business Process is PA1003 Pcard Administration
    Test Scenario is PA1003-01 Create Reconciler Workgroup
    As of Sep 20, 2011, this functional test is out of date:
    Group is no longer on the Administration panel.

    Given I am logged in
    And   I am on the "main_menu" tab
    When I click the "Group" portal link
    And I click "create new"
    And I click "search"
    And I return the "Organization Group" one
    And I set the "Description" to something like "testing: PA1003-01"
    And I set the "Group Namespace" to "KFS-FP - Financial Processing"
    And I set the "Group Name" to something like "PA1003-01"
    And I set the "Chart Code" to "UA - University of Arizona-Management"
    And I set the "Organization Code" to "PCRD"
    And I click "submit"
    And I show the "Route Log" tab
    Then I should see "ID:" in the route log
    And  I should see "Actions Taken" in the route log
    And  I should see "Pending Action Requests" in the route log
    And  I should see "ENROUTE" in the route log
    # In the functional scenario, the document should automatically go to final.
    # Now a member of "UA PACS PCard Administrators" must approve.
    When I record this document number
    And I backdoor as "kfs-test-sec19"
    And I open my Action List
    And I open that document
    And I click "approve"

  @funky_test
  Scenario: PA1003-02
    Business Process is PA1003 Pcard Administration
    Test Scenario is PA1003-02 Assign Reconciler to Workgroup

    Given I am logged in
    And   I am on the "main_menu" tab
    When I click the "Group" portal link
    And I click "create new"
    And I click "search"
    And I return the "Organization Group" one
    And I set the "Description" to something like "testing: PA1003-01"
    And I set the "Group Namespace" to "KFS-FP - Financial Processing"
    And I set the "Group Name" to something like "PA1003-02"
    And I set the "Chart Code" to "UA - University of Arizona-Management"
    And I set the "Organization Code" to "PCRD"
    And I set a new Assignee's "Type Code" to "Principal"
    And I start a lookup for the new Assignee's "Member Identifier"
    And I set the "First Name" to "Samuel*"
    And I set the "Last Name" to "Rawlins"
    And I click "search"
    And I return with the first result
    And I add that "Assignee"
    And I click "submit"
    And I show the "Route Log" tab
    Then I should see "ID:" in the route log
    And  I should see "Actions Taken" in the route log
    And  I should see "Pending Action Requests" in the route log
    And  I should see "ENROUTE" in the route log

Feature: KFSI-5638

  Background:
    Given I am up top

  @jira
  Scenario: Searching under Asset Retirement Global doesn't blow up.

    Given I am logged in
    And I am on the "central_admin" tab
    When I click the "Asset Retirement Global" portal link
    And I click "search"
    Then I shouldn't see an incident report
    And I shouldn't get an HTTP Status 500

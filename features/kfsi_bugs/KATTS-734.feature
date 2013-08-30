Feature: KATTS-734

  Background:
    Given I am up top

  @jira
  Scenario: Viewing Role 11173 shouldn't blow up.

    Given I am logged in
    And I am on the "administration" tab
    When I click the "Role" portal link
    And I set the "Role" to "11173"
    And I click "search"
    And I click the "Base Financial System User" link
    And I switch to the new window
    Then I shouldn't see an incident report
    And I shouldn't get an HTTP Status 500
    And I close that window

Feature: KFSI-5490

  Background:
    Given I am up top

  @jira
  Scenario: Vendor creation can be cancelled

    Given I am logged in as "kfs-test-sec32"
    And I am on the "main_menu" tab
    When I click the "Vendor" portal link
    And I click "create new"
    And I click "cancel"
    And I click "yes"
    Then I shouldn't get an HTTP Status 500
    And I shouldn't see an incident report


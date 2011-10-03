Feature: KFSI-5637

  Background:
    Given I am up top

  @jira
  Scenario: Regular expression parsing in EdsPrincipalDaoImpl is complete

    Given I am logged in
    When I open a doc search
    And I start a lookup for "Initiator"
    And I set the "First Name" to "Sam\"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam^"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam["
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam."
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam$"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam{"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam*"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam("
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam+"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam)"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam|"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam?"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam<"
    And I click "search" and wait
    Then I shouldn't see an incident report
    When I set the "First Name" to "Sam>"
    And I click "search" and wait
    Then I shouldn't see an incident report

@not_a_test
Feature: Stuck Document

  Background:
    Given I am up top

  Scenario: Document Requeuer requeues a document successfully

    Given I am logged in
    And   I am on the "administration" tab
    When I click the "Document Operation" portal link
    And I slow down
    And I set the "Document ID" to the given document number
    And I click "get document"
    And I highlight the "Queue Document Requeuer" submit button
    And I sleep for "2" seconds
    And I click the "Queue Document Requeuer" submit button
    And I scroll to the image with alt text "Workflow"
    Then I should see "Document Requeuer was successfully scheduled"
    And I enlargen "Document Requeuer was successfully scheduled"
    And I sleep for "5" seconds


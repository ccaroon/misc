Feature: Story Detail Page

Background:
    Given I am on an Aurora web site in:
        | ff     |
        | chrome |
    When I navigate to a story detail page

Scenario: Should display the Facebook Like button
    Then the Facebook Like button should be displayed

Feature: Story Detail Page

As a reader
In order to read a story
I want to view the story detail page

Background:
    Given I am on an Aurora web site in:
        | ff  | http://ccaroon-red-site.apps.nandomedia.com |
    And I navigate to a story detail page

@breadcrumb
Scenario: Breadcrumb
    When I click on the section name in the breadcrumb
    Then the corresponding section front page should display

@breadcrumb_position
Scenario: Breadcrumb Position
    Then the breadcrumb should be below the NavBar
    And it should be above the Story headline

@commenting
Scenario: Comment link in breadcrumb bar
    When I click on the comment count in the breadcrumb bar
    Then I am taken to the Disqus commenting on the story detail page

@facebook
Scenario: Facebook Like button
    Then the Facebook Like button should be displayed

@headline
Scenario: Headline
    Then the story headline is present
    And the font is larger than the story body

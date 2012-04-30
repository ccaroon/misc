Feature: Feedback when entering invalid credit card details.

    In user testing, blah blah blah...
    be helpful.

    Background:
        Given I have chosen some items to buy
        And I am about to enter my credit card details

    Scenario: Credit card number too short
        When I enter a card number that's only 15 digits long
        And all the other details are correct
        And I submit the form
        Then the form should be redisplayed
        And I should see a message advising me of the correct number of digits

    Scenario: Expiry date invalid
        When I enter a card expiry date that's in the past
        And all the other details are correct
        And I submit the form
        Then the form should be redisplayed
        And I should see a message telling me the expiry data must be wrong


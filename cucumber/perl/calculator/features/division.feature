Feature: Division

Scenario: Dividing two numbers
    Given the input "<input>"
    When the calculator is run
    Then the output should be "<output>"
    Examples:
        | input | output |
        | 2/2   | 1.0    |
        | 98/1  | 98.0   |
        | 100/2 | 50.0   |
        | 0/73  | 0.0    |
        | 3/2   | 1.5    |

Scenario: Division by zero
    Given the input "1/0"
    When the calculator is run
    Then the output should be "Error - Division by Zero!"


#!/bin/env python
import sys

from lib.puzzle import Puzzle

# ------------------------------------------------------------------------------
if __name__ == "__main__":
    puzzle_name = None
    if len(sys.argv) < 2:
        print(F"Usage: {sys.argv[0]} <puzzle_name>")
        sys.exit(1)
    else:
        puzzle_name = sys.argv[1]

    puzzle = Puzzle(puzzle_name)

    print(puzzle)

    found = puzzle.auto_search()

    for word, location in found.items():
        if location:
            print(F"Found '{word}' at {location[0]},{location[1]} heading {location[2]}")
        else:
            print(F"Not Found: '{word}")

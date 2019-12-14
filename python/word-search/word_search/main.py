#!/bin/env python
import sys
import yaml

from lib.diagram import Diagram

# ------------------------------------------------------------------------------
def search(puzzle):
    found_count = 0

    words = puzzle.get('words', [])
    diagram = Diagram(puzzle['diagram'])

    print(diagram)

    for word in words:
        if diagram.find_word(word):
            found_count +=1
        else:
            print(F"Unable to find '{word}'")

    word_count = len(words)

    print(F"---------------------------------------")
    print(F"Found {found_count}/{word_count} words.")

# ------------------------------------------------------------------------------
if __name__ == "__main__":
    puzzle_name = None
    if len(sys.argv) < 2:
        print(F"Usage: {sys.argv[0]} <puzzle_name>")
        sys.exit(1)
    else:
        puzzle_name = sys.argv[1]

    puzzle = {}
    with open(F"./puzzles/{puzzle_name}.yml") as file:
        puzzle = yaml.full_load(file)

    search(puzzle)

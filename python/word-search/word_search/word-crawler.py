#!/bin/env python
import sys

import adventurelib
import random

import lib.word_crawler.context.contexts as contexts
from lib.word_crawler.context.context import Context

import lib.word_crawler.game.commands
from lib.word_crawler.scenes.intro import scene as intro

from lib.puzzle import Puzzle
# ------------------------------------------------------------------------------
def prompt():
    if Context.ACTIVE:
        return F"WC - {Context.get()}> "
    else:
        return F"WC> "

def invalid_command(cmd):
    print(random.choice([
        "Huh?",
        F"I don't know how to '{cmd}'",
        "Ummm...what?"
    ]))

# ------------------------------------------------------------------------------
if __name__ == "__main__":
    puzzle_name = None
    if len(sys.argv) < 2:
        print(F"Usage: {sys.argv[0]} <puzzle_name>")
        sys.exit(1)
    else:
        puzzle_name = sys.argv[1]

    puzzle = Puzzle(puzzle_name)
    in_puzzle = Context("Search Mode", icon='🔍', data=puzzle)
    in_puzzle.activate()

    adventurelib.prompt = prompt
    adventurelib.no_command_matches = invalid_command

    # Context.add(contexts.CHEATING)

    intro.play()
    adventurelib.start(help=True)

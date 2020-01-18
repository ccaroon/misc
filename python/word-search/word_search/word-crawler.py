#!/bin/env python
import sys

import adventurelib
import random

from colorama import Fore

import lib.word_crawler.context.contexts as contexts
from lib.word_crawler.context.context import Context

from lib.word_crawler.scenes.cut_scene import CutScene

import lib.word_crawler.game.commands
from lib.word_crawler.scenes.intro import scene as intro

from lib.word_crawler.rooms.puzzle_dungeon import PuzzleDungeon
from lib.word_crawler.rooms.entrance import room as entrance
from lib.word_crawler.inventory.object import Object
from lib.word_crawler.inventory import INVENTORY

from lib.word_crawler.game import GAME_MAP

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
    dungeon = PuzzleDungeon(puzzle)

    size = puzzle.size()
    GAME_MAP.set_size(size[0], size[1])
    GAME_MAP.fill()

    word_list = Object(
        "word list",
        " | ".join(puzzle.word_list()),
        aliases=("list of words",),
        color=Fore.LIGHTBLUE_EX
    )
    word_search = Object(
        "word search puzzle",
        F"A Word Search Puzzle titled '{puzzle.title}'. Too bad you don't have a pencil.",
        aliases=('word search', 'puzzle',),
        color=Fore.MAGENTA,
        undroppable=True,
        real_obj=puzzle
    )
    word_search.items.add(word_list)
    INVENTORY.add(word_search)

    first_room = dungeon.get_room(0,0)
    entrance.east = first_room

    first_room.enter_scene = CutScene("Opening the Ancient Door")
    first_room.enter_scene.add_dialogue("""
    You spy a small crack in the ancient stone door and just manage to insert your fingers
    enough to get a good grip. You pull on the door with all your might and just as
    you're about to give up, the door slides sideways and completely disentigrates in
    a cloud of dust.
    """)
    first_room.enter_scene.add_dialogue("""
    As you are stepping through the portal your word search puzzle starts to give
    off a faint light.
    """)
    first_room.enter_scene.add_dialogue("""Your entire body starts to tingle.""")
    first_room.enter_scene.add_dialogue("""Then with a final crack, pop and fizzle...""")
    def crumble_door():
        door = entrance.objects.find('stone door')
        door.state = "big pile of rubble"
    first_room.enter_scene.add_action(crumble_door, pause=False)

    adventurelib.prompt = prompt
    adventurelib.no_command_matches = invalid_command

    # Context.add(contexts.CHEATING)

    intro.play()
    adventurelib.start(help=True)

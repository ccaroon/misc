import sys

import lib.word_crawler.helpers.screen as screen
import lib.word_crawler.items.entrance as items
from lib.word_crawler.scenes.cut_scene import CutScene

from .space import Space
# ------------------------------------------------------------------------------
room = Space(
    "Exit",
    F"""
Ahhhh ... Sunshine!
""",
    # items=[items.lantern],
    # objects=[
    #     items.door
    # ],
    # north=puzzle_room
)

room.enter_scene = CutScene("Got No Time For This")
room.enter_scene.add_dialogue(F"""You ain't got time for this! You head off out of the
cavern in search of a pencil.
""")
room.enter_scene.add_action(sys.exit)

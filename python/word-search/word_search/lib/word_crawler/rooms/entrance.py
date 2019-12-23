import lib.word_crawler.helpers.screen as screen
import lib.word_crawler.items.entrance as items

from .puzzle import room as puzzle_room
from .space import Space
# ------------------------------------------------------------------------------
room = Space(
    "Entrance",
    F"""
You are standing just inside the entrace to a cavern. Directly in front of you is a {items.door.state_desc()}.
""",
    items=[items.lantern],
    objects=[
        items.door
    ],
    north=puzzle_room
)

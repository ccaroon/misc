import lib.word_crawler.helpers.screen as screen
import lib.word_crawler.items.entrance as items

from .exit import room as exit_room
from .space import Space
# ------------------------------------------------------------------------------
room = Space(
    "Entrance",
    F"""
You are standing just inside the entrace to a cavern. Directly in front of you is a {items.door.state_desc()}.

The mouth of the cave, the only way out of here, is to the south.
""",
    items=[items.lantern],
    objects=[
        items.door
    ],
    south=exit_room
)

from colorama import Fore

import lib.word_crawler.rooms
from lib.word_crawler.inventory.object import Object
from lib.word_crawler.scenes.cut_scene import CutScene
# ------------------------------------------------------------------------------
# ITEMS - Things that can be picked up and carried in the inventory
# ------------------------------------------------------------------------------
red_key = Object(
    "red key",
    "It's a small, red key.",
    color=Fore.RED
)

# TODO: better name & desc
note_1 = Object(
    "rectangular note",
    "A note card with a pattern on it.",
    color=Fore.BLUE
)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OBJECTS - "Static" object in the room. Can be interacted with, but not picked up
# ------------------------------------------------------------------------------
door = Object("door",
    "Solid, wooden door. A giant '5' has been scrawled on the back of the door with, what you hope is, red paint.",
    state="locked"
)

pillow = Object(
    "pillow",
    "A dingy, blue stripped pillow without a pillowcase.",
    color=Fore.BLUE
)
pillow.items.add(note_1)

bunks_1 = Object(
    "dingy bunk beds",
    "A dingy bunk bed stack, three levels high, with a ladder to the top.",
    aliases=("dingy bunks", "dingy beds", "right bunks"),
)
bunks_1.items.add(pillow)

bunks_2 = Object(
    "filthy bunk beds",
    "A filthy bunk bed stack, three levels high, with a ladder to the top.",
    aliases=("filthy bunks", "filthy beds", "left bunks"),
)

mirror = Object("mirror", "A floor-length mirror. You can see your whole self in it.", color=Fore.BLUE)
mirror.items.add(red_key)

table = Object(
    "table",
    "A picnic style table complete with a bench on each side."
)

porthole = Object(
    "porthole",
    "A smallish, round window. It's too dark and foggy outside to see anything.",
    aliases=("window",),
    state="closed",
    color=Fore.CYAN
)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# SCENES -
# ------------------------------------------------------------------------------
pillow.scene = CutScene("Move Pillow")
pillow.scene.add_dialogue(F"""
You move the pillow aside revealing a {note_1}
""")
# ------------------------------------------------------------------------------
mirror.scene = CutScene("Mirror Reveal")
mirror.scene.add_dialogue(F"""
The mirror is covered with a pull-down shade for some odd reason. As you reach out to touch it the shade suddenly rolls itself up.
Ah! There you are.

You see a {red_key} taped to the mirror.
""")
# ------------------------------------------------------------------------------
def end_portal_cracking():
    porthole.state = "has blown wide open; water is pouring into the room"

porthole.scene = CutScene("Portal Cracking")
porthole.scene.add_dialogue(F"""
You look out the porthole into the dark and foggy night. You can't really see anything. However, the presence of a porthole makes you feel
pretty surely that you are definetely on a ship.
""")
porthole.scene.add_dialogue(F"""
The ship shakes violently almost knocking you off your feet. As you regain your balance you notice that the {porthole} is starting to crack and that water is starting to seep into the room.
""")
porthole.scene.add_dialogue(F"""
It's official. The {porthole} has blown open and sea water is pouring into the room in massive quantities.
I's already ankle deep.
""")
porthole.scene.add_action(end_portal_cracking, pause=False)
# ------------------------------------------------------------------------------

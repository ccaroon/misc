from colorama import Fore

# import lib.word_crawler.rooms
from lib.word_crawler.inventory.object import Object
# from lib.word_crawler.scenes.cut_scene import CutScene
# ------------------------------------------------------------------------------
# ITEMS - Things that can be picked up and carried in the inventory
# ------------------------------------------------------------------------------
lantern = Object(
    "lantern",
    "It's a handheld propane lantern. It gives off a sickly, green glow.",
    color=Fore.GREEN
)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OBJECTS - "Static" object in the room. Can be interacted with, but not picked up
# ------------------------------------------------------------------------------
door = Object("stone door",
    "A stone door. Looks ancient. You **might** just be able to open it.",
    aliases=('door',),
    isa=("door",),
    color=Fore.WHITE,
    state="crumbling"
)

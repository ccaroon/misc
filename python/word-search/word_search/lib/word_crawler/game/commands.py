from adventurelib import *

import lib.word_crawler.context.contexts as contexts
from lib.word_crawler.context.context import Context

from lib.word_crawler.inventory import INVENTORY
from lib.word_crawler.rooms import CURRENT_ROOM

# ------------------------------------------------------------------------------
# Game
# ------------------------------------------------------------------------------
@when("save")
def save_state():
    say("Saving has not yet been implemented!")
# ------------------------------------------------------------------------------
# Inventory Related Commands
# ------------------------------------------------------------------------------
@when("i")
@when("inventory")
def view():
    if INVENTORY:
        print(F"You're carrying {len(INVENTORY)} items:")
        for item in INVENTORY:
            print(F"{item} - {item.isa}")
    else:
        print("You have nothing!")

@when("take THING from OBJECT")
@when("take THING off OBJECT")
@when("remove THING from OBJECT")
def take_item1(thing, object):
    obj = CURRENT_ROOM.objects.find(object)

    if obj:
        item = obj.items.take(thing)
        if item:
            INVENTORY.add(item)
            say(F"You remove the {item} from the {obj}.")
        else:
            say(F"You don't see a {thing} on the {object}")
    else:
        say(F"You don't see any {object} in here.")

@when("pick up THING")
@when("take THING")
def take_item2(thing):
    item = CURRENT_ROOM.items.take(thing)
    if item:
        INVENTORY.add(item)
        print(F"You take the {thing}.")
    else:
        obj = CURRENT_ROOM.objects.find(thing)
        if obj:
            say(F"You can't pick that up.")
        else:
            say(F"You don't see any {thing} here.")

@when("drop THING")
def remove_item(thing):
    item = INVENTORY.take(thing)
    if item:
        CURRENT_ROOM.items.add(item)
        say(F"Dropped {thing}.")
    else:
        say(F"You're not even carrying a {thing}.")

@when("examine THING")
@when("x THING")
@when("look at THING")
def examine(thing):
    item = INVENTORY.find(thing)
    if not item:
        item = CURRENT_ROOM.objects.find(thing)

    if item:
        say(item.describe())
    else:
        say(F"You don't have any {thing}.")
# ------------------------------------------------------------------------------
# Room Related Commands
# ------------------------------------------------------------------------------
@when("l")
@when("look")
def look():
    say(F"--- {CURRENT_ROOM.name} ---")
    say(CURRENT_ROOM.description)

    # TODO: better incorporate items in to the narrative
    if CURRENT_ROOM.items:
        print("\nLooking around you reveals: ")
        for thing in CURRENT_ROOM.items:
            print(thing)

    # TODO: better incorporate exits in to the narrative
    exits = CURRENT_ROOM.exits()
    if exits:
        print(F"\nExits: {exits}")

@when("map")
def map():
    say("Sure would be nice to have a map of this place.")
# ------------------------------------------------------------------------------
# Movement
# ------------------------------------------------------------------------------
@when("exit")
def leave():
    global CURRENT_ROOM

    exits = CURRENT_ROOM.exits()
    if len(exits) > 1:
        say(F"""
            There's more than one way to leave this room. Which one would you like to try?
            {exits}
        """)
    elif len(exits) == 0:
        print("There doesn't appear to be any way out of here! You're trapped! Forever!")
    else:
        CURRENT_ROOM = CURRENT_ROOM.exit(exits[0])
        print(CURRENT_ROOM)

@when('n', direction='north')
@when('ne', direction='northeast')
@when('e', direction='east')
@when('se', direction='southeast')
@when('s', direction='south')
@when('sw', direction='southwest')
@when('w', direction='west')
@when('nw', direction='northwest')
def move(direction):
    global CURRENT_ROOM

    room = CURRENT_ROOM.exit(direction)
    if room:
        CURRENT_ROOM = room
        print(CURRENT_ROOM)
    else:
        say(F"You can't move {direction}.")
# ------------------------------------------------------------------------------
# Cheating
# ------------------------------------------------------------------------------
@when("context ACTION", context="cheating")
def context(action):
    if action == "clear":
        Context.clear()
        Context.add(contexts.CHEATING)
    elif action == "show":
        print(get_context())
    elif action.startswith("add"):
        status = action.replace("add", "")
        ctx = Context(status.strip())
        Context.add(ctx)

@when("cheat ACTION", context="cheating")
def cheat(action):
    print(F"Unknown cheat command '{action}'.")









#

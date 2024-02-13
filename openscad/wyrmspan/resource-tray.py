#!/usr/bin/env python
from solid2 import *

import shared_lib

# Real Values
TRAY_LENGTH = 115
TRAY_WIDTH = 50
TRAY_HEIGHT = 40
TRAY_WALL = 1.5

# TEST Print Values
# TRAY_HEIGHT = 5
# TRAY_WALL = 1.5


def resource_tray():
    length = TRAY_LENGTH // 2
    width = TRAY_WIDTH // 2

    slot1 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot2 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot3 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot4 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)

    tray = slot1 + \
        slot2.translate([length+TRAY_WALL, 0, 0]) + \
        slot3.translate([0, -width-TRAY_WALL, 0]) + \
        slot4.translate([length+TRAY_WALL, -width-TRAY_WALL, 0])

    return tray


if __name__ == "__main__":
    rsrc_tray = resource_tray()

    rsrc_tray.save_as_scad("./resource-tray.scad")

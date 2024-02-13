#!/usr/bin/env python
from solid2 import *

import shared_lib

# Real Values
TRAY_WIDTH = 57.5
TRAY_LENGTH = 40
TRAY_HEIGHT = 40
TRAY_WALL = 1.80
TRAY_RND = 3

# TEST Print Values
# TRAY_HEIGHT = 5


def resource_tray():
    tray = shared_lib.compartment_box(
        TRAY_WIDTH, TRAY_LENGTH,
        TRAY_HEIGHT, TRAY_WALL,
        count=4, rows=2,
        rounding=TRAY_RND
    )

    return tray


if __name__ == "__main__":
    set_global_fn(150)
    rsrc_tray = resource_tray()
    rsrc_tray.save_as_scad("./resource-tray.scad")

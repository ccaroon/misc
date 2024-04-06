#!/usr/bin/env python
from solid2 import *

from lib import boxes
from lib import units

# Real Values
CMPT_WIDTH = (11.0/2) * units.cm
CMPT_LENGTH = (7.25/2) * units.cm
TRAY_HEIGHT = 2.5 * units.cm
TRAY_WALL = 1.5
TRAY_RND = 3

# TEST Print Values
# TRAY_HEIGHT = 10


def resource_tray():
    tray = boxes.compartment_box(
        CMPT_WIDTH, CMPT_LENGTH,
        TRAY_HEIGHT, TRAY_WALL,
        count=4, rows=2,
        rounding=TRAY_RND
    )

    return tray


if __name__ == "__main__":
    set_global_fn(150)
    rsrc_tray = resource_tray()
    rsrc_tray.save_as_scad("./models/wyrm-resource_tray.scad")

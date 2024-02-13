#!/usr/bin/env python
from solid2 import *
import shared_lib

# Real Values
TRAY_HEIGHT = 35
TRAY_WALL = 2.5

# TEST Print Values
# TRAY_HEIGHT = 10
# TRAY_WALL = 1

DRAGON_CARD = {
    "width": 57.4,
    "length": 87.5
}

CAVE_CARD = {
    "width": 57.4,
    "length": 57.5
}


def dragon_tray_dims():
    width = (TRAY_WALL * 4) + (DRAGON_CARD.get("width") * 3)
    length = (TRAY_WALL * 2) + (DRAGON_CARD.get("length"))

    return length, width


def dragon_tray():
    width = DRAGON_CARD.get("length")
    length = DRAGON_CARD.get("width")
    dims = dragon_tray_dims()

    slot1 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot2 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot3 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)

    cutout_r = 30.0
    cutout = cylinder(h=dims[1]+TRAY_WALL*2, r=cutout_r).rotate([90,0,90])

    tray = slot1 + \
           slot2.translate([length+TRAY_WALL, 0, 0]) + \
           slot3.translate([(length+TRAY_WALL)*2, 0, 0]) - \
           cutout.translate([-TRAY_WALL, dims[0]//2, cutout_r+TRAY_WALL])

    return tray


def cave_tray_dims():
    width = (TRAY_WALL * 4) + (CAVE_CARD.get("width") * 2)
    length = (TRAY_WALL * 2) + (CAVE_CARD.get("length"))

    return length, width


def cave_tray():
    width = CAVE_CARD.get("length")
    length = CAVE_CARD.get("width")
    dims = cave_tray_dims()

    slot1 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot2 = shared_lib.open_box(length, width, TRAY_HEIGHT, TRAY_WALL)

    cutout_r = 25.0
    cutout = cylinder(h=dims[1]+TRAY_WALL*2, r=cutout_r).rotate([90,0,90])

    tray = slot1 + slot2.translate([length+TRAY_WALL, 0, 0]) - \
           cutout.translate([-TRAY_WALL, dims[0]//2, cutout_r+TRAY_WALL])

    return tray


if __name__ == "__main__":
    dtray_dims = dragon_tray_dims()
    dtray_length = dtray_dims[0]
    dtray_width = dtray_dims[1]

    ctray_dims = cave_tray_dims()
    ctray_length = ctray_dims[0]

    dtray = dragon_tray()
    ctray = cave_tray()

    card_tray = dtray + ctray.translate([
        (dtray_width // 2) - (CAVE_CARD.get("width") + TRAY_WALL),
        -ctray_length + TRAY_WALL,
        0
    ])

    card_tray.save_as_scad("./card-tray.scad")

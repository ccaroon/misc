#!/usr/bin/env python
from solid2 import *
import shared_lib

# Real Values
TRAY_HEIGHT = 35
TRAY_WALL = 2.5
TRAY_RND = 3

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
    dims = dragon_tray_dims()

    tray = shared_lib.compartment_box(
        DRAGON_CARD.get("width"), DRAGON_CARD.get("length"),
        TRAY_HEIGHT, TRAY_WALL,
        count=3, rows=1,
        rounding=TRAY_RND
    )

    cutout_r = 30.0
    cutout = cylinder(h=dims[1]+TRAY_WALL*4, r=cutout_r).rotate([90,0,90])

    tray -= cutout.translate([-TRAY_WALL*2, dims[0]//2, cutout_r+TRAY_WALL])

    return tray


def cave_tray_dims():
    width = (TRAY_WALL * 4) + (CAVE_CARD.get("width") * 2)
    length = (TRAY_WALL * 2) + (CAVE_CARD.get("length"))

    return length, width


def cave_tray():
    dims = cave_tray_dims()

    tray = shared_lib.compartment_box(
        CAVE_CARD.get("width"), CAVE_CARD.get("length"),
        TRAY_HEIGHT, TRAY_WALL,
        count=2, rows=1,
        rounding=TRAY_RND
    )

    cutout_r = 25.0
    cutout = cylinder(h=dims[1]+TRAY_WALL*4, r=cutout_r).rotate([90,0,90])

    tray -= cutout.translate([-TRAY_WALL*2, dims[0]//2, cutout_r+TRAY_WALL])

    return tray


if __name__ == "__main__":
    set_global_fn(150)
    dtray_dims = dragon_tray_dims()
    dtray_length = dtray_dims[0]
    dtray_width = dtray_dims[1]

    ctray_dims = cave_tray_dims()
    ctray_length = ctray_dims[0]

    dtray = dragon_tray()
    ctray = cave_tray()

    card_tray = dtray + ctray.translate([
        (dtray_width / 2) - (CAVE_CARD.get("width") + TRAY_WALL*1.5),
        -ctray_length + TRAY_WALL-(TRAY_RND//2),
        0
    ])

    card_tray.save_as_scad("./card-tray.scad")

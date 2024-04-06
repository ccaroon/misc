#!/usr/bin/env python
import argparse

from solid2 import *

from lib import boxes
from lib import units

# Real Values
TRAY_HEIGHT = 3.25 * units.cm
TRAY_WALL = 1.5 * units.mm
TRAY_RND = 3 * units.mm
COMP_PADDING = 1.25 * units.mm

# TEST Print Values
# TRAY_HEIGHT = 10
# TRAY_WALL = 1.6

DRAGON_CARD = {
    "width": 2.25*units.inch,
    "length": 8.75*units.cm
}

CAVE_CARD = {
    "width": 2.25*units.inch,
    "length": 2.25*units.inch
}


def dragon_tray_dims():
    width = (TRAY_WALL * 4) + (DRAGON_CARD.get("width") * 3)
    length = (TRAY_WALL * 2) + (DRAGON_CARD.get("length"))

    return length, width


def dragon_tray():
    dims = dragon_tray_dims()

    tray = boxes.compartment_box(
        DRAGON_CARD.get("width") + COMP_PADDING,
        DRAGON_CARD.get("length") + COMP_PADDING,
        TRAY_HEIGHT, TRAY_WALL,
        count=3, rows=1,
        rounding=TRAY_RND
    )

    cutout_r = 30.0
    cutout_h = dims[1] + (TRAY_WALL + TRAY_RND) * 2
    cutout = cylinder(h=cutout_h, r=cutout_r).rotate([90,0,90])

    tray -= cutout.translate([
        -(TRAY_WALL+TRAY_RND+TRAY_WALL),
        dims[0] // 2,
        cutout_r + TRAY_WALL
    ])

    return tray


def cave_tray_dims():
    width = (TRAY_WALL * 4) + (CAVE_CARD.get("width") * 2)
    length = (TRAY_WALL * 2) + (CAVE_CARD.get("length"))

    return length, width


def cave_tray():
    dims = cave_tray_dims()

    tray = boxes.compartment_box(
        CAVE_CARD.get("width") + COMP_PADDING,
        CAVE_CARD.get("length") + COMP_PADDING,
        TRAY_HEIGHT, TRAY_WALL,
        count=2, rows=1,
        rounding=TRAY_RND
    )

    cutout_r = 25.0
    cutout_h = dims[1] + (TRAY_WALL + TRAY_RND) * 2
    cutout = cylinder(h=cutout_h, r=cutout_r).rotate([90,0,90])

    tray -= cutout.translate([
        -(TRAY_WALL+TRAY_RND+TRAY_WALL),
        dims[0] // 2,
        cutout_r + TRAY_WALL
    ])

    return tray


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate Card Trays for Wyrmspan")
    parser.add_argument(
        "type",
        nargs="?",
        choices=("cave","dragon","combo"),
        default="combo"
    )
    args = parser.parse_args()

    set_global_fn(150)

    if args.type in ("dragon", "combo"):
        dtray_dims = dragon_tray_dims()
        dtray_length = dtray_dims[0]
        dtray_width = dtray_dims[1]

        dtray = dragon_tray()
        card_tray = dtray

    if args.type in ("cave", "combo"):
        ctray_dims = cave_tray_dims()
        ctray_length = ctray_dims[0]

        ctray = cave_tray()
        card_tray = ctray


    # Combo Dragon & Cave Card Tray
    if args.type == "combo":
        card_tray = dtray + ctray.translate([
            (dtray_width / 2) - (CAVE_CARD.get("width") + TRAY_WALL*1.5),
            -ctray_length,
            0
        ])

    card_tray.save_as_scad("./models/wyrm-card_tray.scad")

#!/usr/bin/env python
from solid2 import *
import units

TRAY_HEIGHT = 35
TRAY_WALL = 2.5

DRAGON_CARD = {
    "width": 57.4,
    "length": 87.5
}

CAVE_CARD = {
    "width": 57.4,
    "length": 57.5
}


def open_box(length, width, height, wall):
    """
    Create an open-top box with INSIDE dims of `length`, `width` & `height` with
    outer walls & bottom of `wall` thickness.

    :param length: Inside length
    :param width:  Inside width
    :param height: Inside height
    :param wall:  Bottom & wall thickness
    :return: Box object
    """
    outer_box = cube([length+(wall*2), width+(wall*2), height+wall])
    inner_box = cube([length, width, height+wall])

    box = outer_box - inner_box.translate([wall,wall,wall])

    return box


def dragon_tray():
    width = DRAGON_CARD.get("length")
    length = DRAGON_CARD.get("width")

    slot1 = open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot2 = open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot3 = open_box(length, width, TRAY_HEIGHT, TRAY_WALL)

    tray = slot1 + \
           slot2.translate([length+TRAY_WALL, 0, 0]) + \
           slot3.translate([(length+TRAY_WALL)*2, 0, 0])

    return tray


def cave_tray():
    width = CAVE_CARD.get("length")
    length = CAVE_CARD.get("width")

    slot1 = open_box(length, width, TRAY_HEIGHT, TRAY_WALL)
    slot2 = open_box(length, width, TRAY_HEIGHT, TRAY_WALL)

    tray = slot1 + slot2.translate([length+TRAY_WALL, 0, 0])

    return tray


if __name__ == "__main__":
    dtray_width = (TRAY_WALL * 4) + (DRAGON_CARD.get("width") * 3)
    dtray_length = (TRAY_WALL * 2) + (DRAGON_CARD.get("length"))

    ctray_length = (TRAY_WALL * 2) + (CAVE_CARD.get("length"))

    dtray = dragon_tray()
    ctray = cave_tray()

    card_tray = dtray + ctray.translate([
        (dtray_width // 2) - (CAVE_CARD.get("width") + TRAY_WALL),
        -ctray_length + TRAY_WALL,
        0
    ])

    card_tray.save_as_scad("./card-tray.scad")

#!/usr/bin/env python
from solid2 import *

MARIO_QMARK = {
    "width": 7,
    "height": 10,
    "bitmap": [
        0,1,1,1,1,1,0,
        1,1,0,0,0,1,1,
        1,1,0,0,0,1,1,
        1,1,0,0,0,1,1,
        0,0,0,0,1,1,1,
        0,0,0,1,1,0,0,
        0,0,0,1,1,0,0,
        0,0,0,0,0,0,0,
        0,0,0,1,1,0,0,
        0,0,0,1,1,0,0,
    ]
}

def pixel_art(pattern, size, **kwargs):
    draw_bg = kwargs.get("draw_bg", False)

    width = pattern["width"]
    bitmap = pattern["bitmap"]
    pixels = []
    for (idx, state) in enumerate(bitmap):
        x = idx % width
        y = idx // width

        if state == 1:
            pixel = cube(size).color("white").right(x*size).back(y*size)
            pixels.append(pixel)
        elif draw_bg:
            pixel = cube(size).color("black").right(x*size).back(y*size)
            pixels.append(pixel)

    pixel_art = union()(pixels)

    return pixel_art

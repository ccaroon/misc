#!/usr/bin/env python
from solid2 import *

from lib import pixel_art
from lib import units

def hollow_cube(size, wall=2):
    outer_cube = cube([size,size,size])
    inner_cube = cube([
        size - (wall*2),
        size - (wall*2),
        size - (wall*2)
    ])

    box = outer_cube - inner_cube.translate([wall,wall,wall])

    return box

# ---MAIN--
cube_size = 1 * units.inch
cube = hollow_cube(cube_size, 1)

pixel_data = pixel_art.MARIO_QMARK
pixel_size = 2.54*units.mm
art = pixel_art.pixel_art(pixel_data, pixel_size)

x_off = (cube_size // 2) - ((pixel_data["width"] // 2) * pixel_size)
y_off = cube_size - (pixel_size)
item = cube + art.translate([x_off, y_off, cube_size])

# item = art
item.save_as_scad("./money-cube.scad")




























# EOF

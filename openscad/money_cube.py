#!/usr/bin/env python
from solid2 import *

import units

# module hollow_cube(size, wall=2) {
#     // Cube w/in a Cube
#     difference() {
#         cube([size,size,size]);

#         translate([wall,wall,wall])
#             cube([size-(wall*2), size-(wall*2), size-(wall*2)]);
#     }
# }

def hollow_cube(size, wall=2):
    outer_cube = cube([size,size,size])
    inner_cube = cube([
        size - (wall*2),
        size - (wall*2),
        size - (wall*2)
    ])

    box = outer_cube - inner_cube.translate([wall,wall,wall])

    return box


hollow_cube(1 * units.inch, 1).save_as_scad("./money-cube.scad")

from solid2 import *

from lib import units

set_global_fn(75)

width = 2 * units.cm  # distance between holes, too
depth = 1 * units.cm
height = 2 * units.mm


hole = cylinder(d=3.25, h=height+2)

side1 = cylinder(d=1*units.cm, h=height)
side2 = cylinder(d=1*units.cm, h=height).translate([width, 0, 0])


model = hull()(side1, side2)
model = model - hole.translate([0, 0, -1])
model = model - hole.translate([width, 0, -1])

# model = side1 + side2
model.save_as_scad("led-matrix-bracket.scad")

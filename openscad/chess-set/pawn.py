from solid2 import *

import units

def pawn():
    base = cylinder(d=units.pawn_base_width, h=units.base_height)

    x = units.pawn_base_width*.60
    middle1 = cube([x,x,5], center=True)
    middle2 = cylinder(
        d1=units.pawn_base_width*.5,
        d2=units.pawn_base_width*.25,
        h=units.pawn_height
    )
    middle = middle1 + middle2

    top = sphere(d=units.base_width/2)

    piece = base                         + \
            middle.up(units.base_height) + \
            top.up(units.base_height + units.pawn_height)

    return piece

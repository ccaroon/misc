from solid2 import *

import units


def crown():
    c1 = circle(d=1.50)
    c2 = circle(d=1.50)
    c3 = circle(d=1.50)

    ring1 = c1.left((units.base_width/2)+.5).rotate_extrude(angle=360)
    ring2 = c2.left((units.base_width/2)+.125).rotate_extrude(angle=360)
    ring3 = c3.left((units.base_width/2)+0).rotate_extrude(angle=360)

    bottom = ring1 + ring2.up(1) + ring3.up(2)

    middle = cylinder(d1=units.base_width-4, d2=units.base_width-1, h=1*units.cm, _fn=15)

    top = sphere(d=5)

    return bottom + middle + top.up(12)

def queen():
    top = crown()

    queen_prf = import_dxf("./images/queen/Queen-Profile.dxf")
    middle = queen_prf.rotate_extrude(angle=360, _fn=250)

    base = cylinder(d=units.base_width, h=units.base_height)

    piece = base + middle.up(units.base_height) + top.up(units.middle_height+2)
    # piece = middle.up(units.base_height-1) + top.up(units.middle_height+2)
    # piece = base + top.up(10)

    return piece

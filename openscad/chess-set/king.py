from solid2 import *

import units

def cross():
    size = 2.5
    v_height = 12
    h_len = 9
    v_bar = cube([size,size,v_height], center=True)
    h_bar = cube([h_len,size,size], center=True)

    return v_bar + h_bar.up(size)

def crown():
    c1 = circle(d=3)

    ring1 = c1.left((units.base_width/2)-1.5).rotate_extrude(angle=360)

    bottom = ring1

    mid_outer = cylinder(d1=units.base_width-4, d2=units.base_width-1, h=1*units.cm, _fn=5)
    mid_inner = circle(d=8).left(8.5).rotate_extrude(angle=360).up(10.5)

    middle = mid_outer - mid_inner

    top = sphere(d=11)
    pom = cross()

    # return bottom + middle + top.up(12)
    return bottom + middle + top.up(7.75) + pom.up(19)

def king():
    top = crown()

    king_prf = import_dxf("./images/king/King-Profile.dxf")
    middle = king_prf.rotate_extrude(angle=360, _fn=250)

    base = cylinder(d=units.base_width, h=units.base_height)

    piece = base + middle.up(units.base_height) + top.up(units.middle_height)

    return piece

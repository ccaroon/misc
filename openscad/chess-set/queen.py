from solid2 import *

import units

# TODO: Shorten. Less forehead.


def crown():
    c1 = circle(d=2.0)
    # c2 = circle(d=1.0)
    # c3 = circle(d=1.0)
    base_dia = units.base_width / 2

    ring1 = c1.left(10).rotate_extrude(angle=360)
    # ring2 = c2.left((units.base_width/2)+.125).rotate_extrude(angle=360)
    # ring3 = c3.left((units.base_width/2)+0).rotate_extrude(angle=360)

    # bottom = ring1 + ring2.up(1) + ring3.up(2)
    bottom = ring1

    mid_outer = cylinder(
        d1=base_dia + 1.5,
        d2=base_dia + 6.0,
        h=1*units.cm,
        _fn=15
    )
    # donut = circle(d=7.5).left(9.5).rotate_extrude(angle=360).up(10)
    # donut = circle(d=7.5).left(9.45).rotate_extrude(angle=360).up(10.5)
    # donut = circle(d=9.25).left(8.5).rotate_extrude(angle=360).up(10.5)
    mid_inner = circle(d=8).left(8.5).rotate_extrude(angle=360).up(10.5)

    middle = mid_outer - mid_inner

    top = sphere(d=11)
    pom = sphere(d=3)

    # return bottom + middle + top.up(12)
    return bottom + middle + top.up(7.75) + pom.up(14.25)

def queen():
    top = crown()

    queen_prf = import_dxf("./images/queen/Queen-Profile.dxf")
    middle = queen_prf.rotate_extrude(angle=360, _fn=250)

    base = cylinder(d=units.base_width, h=units.base_height)

    piece = base + middle.up(units.base_height) + top.up(units.middle_height+2)
    # piece = top

    return piece

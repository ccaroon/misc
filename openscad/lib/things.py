from solid2 import *

# import units


def screw_hole(hole, wall, height, open_ended=True):
    """
    A Hole...for a ... Screw

    :param hole: Size of the screw/hole in mm
    :param wall:  Thickness of the wall around the hole
    :param height: Height of the overall thing
    :param open_ended: Open all the way thru?

    :return: Scad Object Model
    """
    outer = cylinder(d=wall+hole, h=height, _fn=50)
    inner = cylinder(d=hole, h=height+2, _fn=50)

    adjustment = [0, 0, -1]
    if not open_ended:
        adjustment[2] = 1

    return outer - inner.translate(adjustment)

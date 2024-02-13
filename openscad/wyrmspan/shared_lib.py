from solid2 import *


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

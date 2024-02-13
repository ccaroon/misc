import math
from solid2 import *


def open_box(length, width, height, wall, **kwargs):
    """
    Create an open-top box with INSIDE dims of `length`, `width` & `height` with
    outer walls & bottom of `wall` thickness.

    :param length: Inside length
    :param width:  Inside width
    :param height: Inside height
    :param wall:  Bottom & wall thickness
    :return: Box object
    """
    rounding = kwargs.get("rounding", 0)

    if rounding:
        wall -= (rounding * .75)

    outer_box = cube([length+(wall*2), width+(wall*2), height+wall])
    inner_box = cube([length, width, height+wall])

    if rounding:
        cyl = cylinder(h=1, d=rounding)
        outer_box = minkowski()(cyl, outer_box)

    box = outer_box - inner_box.translate([wall, wall, wall])

    return box


def compartment_box(width, length, height, wall, **kwargs):
    rounding = kwargs.get("rounding", 0)

    count = kwargs.get("count", 1)
    rows = kwargs.get("rows", 1)

    per_row = math.ceil(count / rows)

    # print(f"count: {count} | rows: {rows} | per_row: {per_row}")

    if rounding:
        wall -= (rounding / 4)

    box_width = wall + ((wall * (per_row-1)) + (width * per_row)) + wall
    box_length = wall + ((wall * (rows-1)) + (length * rows)) + wall
    outer_box = cube([box_width, box_length, height+wall])
    if rounding:
        cyl = cylinder(h=1, d=rounding)
        outer_box = minkowski()(cyl, outer_box)

    for row in range(rows):
        for row_idx in range(per_row):
            comp = cube([width, length, height+wall])
            x = wall + (row_idx * width) + (row_idx * wall)
            y = wall + row * length + (row * wall)
            z = wall
            # print(f"row: {row} | idx: {row_idx} | x: {x} | y: {y} | x: {z}")
            outer_box -= comp.translate([x, y, z])

    return outer_box

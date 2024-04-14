#!/usr/bin/env python
from solid2 import *

from lib import units

WIDTH = 1.4 * units.cm
HEIGHT = 1.8 * units.cm
THICKNESS = 1 * units.cm


def explorer():
    return import_(file="../resources/explorer.svg").linear_extrude(
        height=THICKNESS
    ).resize([WIDTH, HEIGHT, THICKNESS])


if __name__ == "__main__":
    set_global_fn(150)
    model = explorer()
    model.save_as_scad("./models/wyrm-explorer.scad")

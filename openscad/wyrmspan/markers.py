#!/usr/bin/env python
from solid2 import *

from lib import units


COUNT = 8
SIZE = 8 * units.mm


def markers():
    markers = cube([SIZE, SIZE, SIZE])
    for i in range(1, 8):
        markers += cube([SIZE, SIZE, SIZE]).translate([(i*SIZE)+(i*2),0,0])

    return markers


if __name__ == "__main__":
    set_global_fn(150)
    model = markers()
    model.save_as_scad("./models/wyrm-markers.scad")

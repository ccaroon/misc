#!/usr/bin/env python
from lib import things
from lib import units

from solid2 import *

if __name__ == "__main__":
    set_global_fn(150)
    die = things.blank_die(1 * units.inch)
    die.save_as_scad("./models/blank_die.scad")

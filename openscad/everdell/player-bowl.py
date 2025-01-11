#!/usr/bin/env python
from solid2 import *

from lib import units

def player_bowl():
    cutout = sphere(d=5.5*units.cm)
    rounder = sphere(d=.5*units.cm)
    # rounder = cylinder(d=10)
    bowl = cylinder(r1=2*units.cm, r2=2.85*units.cm, h=3.0*units.cm)

    round_bowl = minkowski()(rounder, bowl)

    return round_bowl - cutout.up(3*units.cm)
    # return bowl - cutout.up(3*units.cm)

if __name__ == "__main__":
    set_global_fn(150)
    model = player_bowl()
    model.save_as_scad("./models/player_bowl.scad")

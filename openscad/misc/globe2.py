from solid2 import *

cm = 10

sph = sphere(d=3*cm, _fn=150)
cutout = cylinder(d=1.5*cm, h=1*cm)

globe = sph.up(1.5*cm) - cutout.translate(0,0,0)

globe.save_as_scad("globe2.scad")

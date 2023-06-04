# SolidPython2 Playground
import solid2
from solid2 import *

set_global_fn(72)

# --- Import SCAD file ---
# boxes = solid2.import_scad("./lib/boxes.scad")
# model = boxes.box(10,10,10, .5).color("lime")

# --- Import Lib Dir ---
# lib = solid2.import_scad("./lib")
# model = lib.boxes.box(5,10,20,.5).down(5)

# --- Box ---
# width = 20
# length = 10
# height = 5
# wall = .5
# outer_box = cube(wall+width+wall, wall+length+wall, height)
# inner_box = cube(width, length, height)

# model = outer_box - inner_box.translate(wall,wall,wall).debug()
# print(model.__class__)

# --- 2D ---
# s = square(5)
# model = s.linear_extrude(height=20, twist=90, slices=50)

# --- minkowski ---
# cube = cube(10,10,1)
# cyl = cylinder(r=2,h=1)
# model = minkowski()(cube, cyl)

model = cube(10)



# --- Save to file ---
model.save_as_scad("./solid-playground.scad")

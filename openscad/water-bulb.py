# import solid2
from solid2 import *
set_global_fn(150)

# units
mm = 1
cm = mm * 10
inch = cm * 2.54

# sizes
wall_thickness = 2 * mm
bulb_size = 3 * inch
tube_size = 1.25 * cm

# bulb
bulb_out = sphere(d=bulb_size)
bulb_in  = sphere(d=bulb_size-wall_thickness)
hole = cylinder(d=tube_size, h=wall_thickness)
bulb = (bulb_out - bulb_in) - hole.up((bulb_size/2)-2)

# tube
tube_out = cylinder(d1=tube_size, d2=tube_size*.75, h=4*inch)
tube_in  = cylinder(
    d1=(tube_size)-wall_thickness,
    d2=(tube_size*.75)-wall_thickness,
    h=(4*inch)+6
)

tube = tube_out - tube_in.down(3)

# assemble
water_bulb = bulb + tube.up((bulb_size/2) - wall_thickness)
# water_bulb = bulb

# output
water_bulb.save_as_scad("./water-bulb.scad")

from lib import boxes
from lib import units

size = 1 * units.inch
padding = .49 * units.mm
padded_size = size + padding

box = boxes.compartment_box(
    padded_size, padded_size, size,
    1.5 * units.mm,
    rounding=3
)

box.save_as_scad("metal-cube-box.scad")

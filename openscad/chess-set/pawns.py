from solid2 import *

def simple(height):
    base_w = height * (1/3)
    base_h = height * (1/3)

    top_size = height * (2/3)

    base = cylinder(d=base_w, h=base_h)

    top = sphere(d=top_size)

    # print(base_w, base_h, top_size)

    return base + top.up(top_size-(top_size*.10))

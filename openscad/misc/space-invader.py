from solid2 import *

# TODO: convert to use lib/pixel_art.py


def invader(size, with_base = False):
    # x, y, y-adjustment
    coords = (
        (2,0,.5), (8,0,.5),
        (3,1), (7,1),
        (2,2), (3,2), (4,2), (5,2), (6,2), (7,2), (8,2),
        (1,3), (2,3), (4,3), (5,3), (6,3), (8,3), (9,3),
        (0,4), (1,4), (2,4), (3,4), (4,4), (5,4), (6,4), (7,4), (8,4), (9,4), (10,4),
        (0,5), (2,5), (3,5), (4,5), (5,5), (6,5), (7,5), (8,5), (10,5),
        (0,6), (2,6), (8,6), (10,6),
        (3,7, -.5), (4,7, -.5), (6,7, -.5), (7,7, -.5)
    )

    base = None
    if with_base:
        base_thickness = .5
        base = cube(11*size,8*size,base_thickness) \
            .color("black")                      \
            .back(7*size)                        \
            .down(base_thickness)

    pixels = []
    for loc in coords:
        px = cube(size).right(loc[0]*size).back(loc[1]*size)
        if len(loc) > 2 and loc[2]:
            px = px.back(loc[2])
        pixels.append(px)

    top = union()(pixels)

    model = None
    if with_base:
        model = base + top
    else:
        model = top

    return model

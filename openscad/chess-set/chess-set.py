from solid2 import *
from units import *

import pawns
import tiles

set_global_fn(50)

# --- Pawns ---
pawn_size = 20*cm
pawn_pieces = []
for num in range(0,8):
    pawn_pieces.append(pawns.simple(pawn_size).translateX(num*(pawn_size/1.25)))
chess_set = union()(pawn_pieces)
# chess_set = pawns.simple(3)

# --- Tiles ---
# chess_set = tiles.hexagon(3*cm,1)




chess_set.save_as_scad("./chess-set.scad")

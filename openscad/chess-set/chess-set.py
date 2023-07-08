import sys
from solid2 import *
from units import *

import king
import pawns
import queen
import tiles

piece = None
if len(sys.argv) > 1:
    piece = sys.argv[1]


set_global_fn(150)

# --- Pawns ---
if piece == "pawn":
    pawn_size = 20*cm
    pawn_pieces = []
    for num in range(0,8):
        pawn_pieces.append(pawns.simple(pawn_size).translateX(num*(pawn_size/1.25)))
    chess_set = union()(pawn_pieces)

# --- Queen ---
if piece == "queen":
    chess_set = queen.queen()

# --- King ---
if piece == "king":
    chess_set = king.king()

# --- Tiles ---
if piece == "tiles":
    chess_set = tiles.hexagon(3*cm,1)


if piece:
    chess_set.save_as_scad(f"./{piece}.scad")

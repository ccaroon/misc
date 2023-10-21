import sys
from solid2 import *
from units import *

import king
import pawn
import queen
import tiles

piece = None
if len(sys.argv) > 1:
    piece = sys.argv[1]


set_global_fn(150)

# --- Pawns ---
if piece == "pawn":
    chess_set = pawn.pawn()

# --- Queen ---
if piece == "queen":
    chess_set = queen.queen()

# --- King ---
if piece == "king":
    chess_set = king.king()

# --- Tiles ---
if piece == "tiles":
    chess_set = tiles.tile(base_width,1)


if piece:
    chess_set.save_as_scad(f"./{piece}.scad")

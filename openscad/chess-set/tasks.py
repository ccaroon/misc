from invoke import task
from solid2 import *
from units import *

import king
import pawn
import queen
import tiles


@task
def build(ctx, piece):
    """
    Build the named chess piece.

    :param piece: The name of the chess piece to build.
    """
    set_global_fn(150)

    model = None
    # --- Pawns ---
    if piece == "pawn":
        model = pawn.pawn()
    # --- Queen ---
    elif piece == "queen":
        model = queen.queen()
    # --- King ---
    elif piece == "king":
        model = king.king()
    # --- Tiles ---
    elif piece == "tiles":
        model = tiles.tile(base_width,1)

    if model:
        file_name = f"./{piece}.scad"
        model.save_as_scad(file_name)
        print(f"=> {file_name}")

@task
def clean(ctx):
    """ Clean up generated files"""
    ctx.run("rm -f *.stl")
    ctx.run("rm -rf __pycache__")

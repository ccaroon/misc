#!/usr/bin/env python
import argparse
from functools import cache

@cache
def hanoi(disk_cnt:int, start_peg:int, work_peg:int, final_peg:int):
    """
    Simulates moving the disks to get the number of moves necessary to
    solve the puzzle.
    """
    moves = 0
    if disk_cnt == 1:
        # move disk from start_peg to final_peg
        # **only** counting moves, not simulating the actual move
        moves += 1
    else:
        moves += hanoi(disk_cnt - 1, start_peg, final_peg, work_peg)
        # move disk from start_pg to final_peg
        # **only** counting moves, not simulating the actual move
        moves += 1
        moves += hanoi(disk_cnt - 1, work_peg, start_peg, final_peg)

    return moves


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compute Tower of Hanoi Moves")

    parser.add_argument("disks", type=int, default=3, help="Number of Disks")
    args = parser.parse_args()

    moves = hanoi(args.disks, 1, 2, 3)
    print(moves)

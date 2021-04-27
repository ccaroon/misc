#!/usr/bin/env python
import random
import sys


def gen_random_points(w, h, count=25):
    points = []
    for i in range(count):
        x = random.randint(0, w)
        y = random.randint(0, h)
        points.append((x,y))

    return(points)

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(F"Usage {sys.argv[0]} <width> <height> <count>")
        sys.exit(1)

    width = int(sys.argv[1])
    height = int(sys.argv[2])
    count = int(sys.argv[3])

    points = gen_random_points(width, height, count)
    
    for point in points:
        print(point)

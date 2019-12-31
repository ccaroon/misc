#!/bin/env python
import random
import re

from lib.grid import Grid
# ------------------------------------------------------------------------------

# Define words
# ------------------------------------------------------------------------------

ROW_PAD = 15
COL_PAD = 15
words = [
    'craig', 'cate', 'nate', 'tootsie',
    'clay', 'christy', 'mason', 'cole', 'bryce', 'scout', 'yoda',
    'neal', 'thersea', 'cougar', 'haley', 'raven',
    'tom thumb', 'linda'
]

print(F"# Words: {len(words)}")

# Find max word length
# ------------------------------------------------------------------------------
max_word_length = 0
for word in words:
    l = len(word)
    if l > max_word_length:
        max_word_length = l

print(F"Max Word Length: {max_word_length}")

# Generate Diagram of random letters
# ------------------------------------------------------------------------------
max_rows = max_word_length + ROW_PAD
max_cols = max_word_length + COL_PAD
diagram = Grid(max_rows, max_cols)
diagram.fill()

for r in range(max_rows):
    for c in range(max_cols):
        diagram.set(r, c, chr(random.randint(65,90)))
# ------------------------------------------------------------------------------
# def word_fits(word, loc):
#     fits = True

#     l = len(word)
#     (row, col, dd) = loc
#     for i in range(l):
#         if diagram.in_bounds(row,col):
#             (row, col) = diagram.direction_to_col_row(dd, row, col)
#         else:
#             fits = False
#             break

#     return fits
# ------------------------------------------------------------------------------
def valid_intersect(v1, v2):
    pass
# ------------------------------------------------------------------------------
def insert_word(word, loc):
    letters = list(re.sub("\s", "", word))
    (row, col, dd) = loc

    for ltr in letters:
        diagram.set(row, col, ltr.upper())
        (row, col) = diagram.direction_to_col_row(dd, row, col)
# ------------------------------------------------------------------------------
def random_loc():
    row = random.randint(0, max_rows)
    col = random.randint(0, max_cols)
    didx = random.randint(0, len(Grid.DIRECTIONS)-1)
    dd = Grid.DIRECTIONS[didx]

    return (row, col, dd)

# loc = random_loc()
# print(loc)
# v = diagram.location_to_vector(loc, 5)
# print(v)

# Insert Words
# RR-CC-DD

# loc = random_loc()
# vector = diagram.location_to_vector(loc)

used_vectors = []
def check_intersection(vector):
    valid = True
    for used_vector in used_vectors:
        i = vector.intersection(used_vector)
        if i:
            valid = False
            break

    return valid


for word in words:
    word_inserted = False

    counter = 0
    # print(F"Working on '{word}'...")
    while not word_inserted and counter < 1000:
        counter += 1
        loc = random_loc()
        vector = diagram.location_to_vector(loc, len(word))
        loc_str = F"{loc[0]:02}-{loc[1]:02}-{loc[2]}"

        if vector and vector not in used_vectors and check_intersection(vector):
            insert_word(word, loc)
            used_vectors.append(vector)
            word_inserted = True

    if word_inserted:
        print(F"'{word}' inserted at {loc_str}.")
    else:
        print(F"FAIL: '{word}' not inserted.")





# ------------------------------------------------------------------------------
print(diagram)
# ------------------------------------------------------------------------------

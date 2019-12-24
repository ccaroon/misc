import re

from lib.grid import Grid

class Diagram:
    # Assumes `data` is a list of strings
    # [
    #   'SOMELETTERSAREHERE',
    #   'MORELETTERSAREHERE'
    # ]
    # --------------------------------------------------------------------------
    def __init__(self, data):
        self.__diagram = []

        for line in data:
            diag_line = list(line)
            self.__diagram.append(diag_line)

        self.__max_row = len(self.__diagram)
        self.__max_col = len(self.__diagram[0])

        self.__grid = Grid(self.__max_row, self.__max_col)

    # --------------------------------------------------------------------------
    def get(self, row, col):
        return self.__diagram[row][col]

    # --------------------------------------------------------------------------
    def size(self):
        return (self.__max_row, self.__max_col)

    # --------------------------------------------------------------------------
    # Return: A tuple with (row, col, direction) indicating where the word was found
    #         or None if not found.
    # Note: row & col will be return as 1-based indexes instead of 0-based
    def find_word(self, word):

        letters = list(re.sub("\s", "", word))

        for f_letter in letters:
            for row, line in enumerate(self.__diagram):
                for col, d_letter in enumerate(line):
                    if d_letter.lower() == f_letter.lower():
                        word_directions = self.__find_the_trail(letters, row, col)
                        for direction in word_directions:
                            found = self.__follow_the_trail(letters, direction, row, col)
                            if found:
                                return (row+1, col+1, direction)

        return None

    def __find_the_trail(self, letters, row, col):
        letter2 = letters[1].lower()

        word_directions = []
        for direction in Grid.DIRECTIONS:
            (new_row, new_col) = self.__grid.direction_to_col_row(direction, row, col)

            if not self.__grid.in_bounds(new_row, new_col):
                continue

            if self.__diagram[new_row][new_col].lower() == letter2:
                word_directions.append(direction)

        return (word_directions)

    def __follow_the_trail(self, letters, direction, row, col):
        current_row = row
        current_col = col

        found = True
        for letter in letters:
            if self.__grid.in_bounds(current_row, current_col) and letter.lower() == self.__diagram[current_row][current_col].lower():
                (current_row, current_col) = self.__grid.direction_to_col_row(direction, current_row, current_col)
            else:
                found = False
                break

        return found



    # --------------------------------------------------------------------------
    def __str__(self):
        output = ""
        for row, line in enumerate(self.__diagram):
            output += F"{row+1:2}: " + " ".join(line) + "\n"

        return(output)

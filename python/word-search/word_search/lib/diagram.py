import re

class Diagram:

    DIRECTIONS = ("N", "NE", "E", "SE", "S", "SW", "W", "NW")

    # Assumes `data` is a list of strings
    # [
    #   'SOMELETTERSAREHERE',
    #   'MORELETTERSAREHERE'
    # ]
    def __init__(self, data):
        self.__diagram = []

        for line in data:
            diag_line = list(line)
            self.__diagram.append(diag_line)

        self.__max_row = len(self.__diagram)
        self.__max_col = len(self.__diagram[0])

        print(F"Rows: {self.__max_row} | Cols: {self.__max_col}")

    # --------------------------------------------------------------------------
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
                                print(F"Found '{word}' at ({row},{col}) heading {direction}")
                                return True

        return False

    def __find_the_trail(self, letters, row, col):
        letter2 = letters[1].lower()

        word_directions = []
        for direction in self.DIRECTIONS:
            (new_row, new_col) = self.__direction_to_col_row(direction, row, col)

            if not self.__in_bounds(new_row, new_col):
                continue

            if self.__diagram[new_row][new_col].lower() == letter2:
                word_directions.append(direction)

        return (word_directions)

    def __in_bounds(self, row, col):
        in_bounds = True
        if row < 0 or row >= self.__max_row:
            in_bounds = False

        if col < 0 or col >= self.__max_col:
            in_bounds = False

        return in_bounds

    def __follow_the_trail(self, letters, direction, row, col):
        current_row = row
        current_col = col

        found = True
        for letter in letters:
            if self.__in_bounds(current_row, current_col) and letter.lower() == self.__diagram[current_row][current_col].lower():
                (current_row, current_col) = self.__direction_to_col_row(direction, current_row, current_col)
            else:
                found = False
                break

        return found

    def __direction_to_col_row(self, direction, row, col):
        new_row = row
        new_col = col

        # N:  col   , row-1
        if direction == "N":
            new_row = row - 1
            new_col = col

        # NE: col+1 , row-1
        elif direction == "NE":
            new_row = row - 1
            new_col = col + 1

        # E:  col+1 , row
        elif direction == "E":
            new_row = row
            new_col = col + 1

        # SE: col+1 , row+1
        elif direction == "SE":
            new_row = row + 1
            new_col = col + 1

        # S:  col   , row+1
        elif direction == "S":
            new_row = row + 1
            new_col = col

        # SW: col-1 , row+1
        elif direction == "SW":
            new_row = row + 1
            new_col = col - 1

        # W:  col-1 , row
        elif direction == "W":
            new_row = row
            new_col = col - 1

        # NW: col-1 , row-1
        elif direction == "NW":
            new_row = row - 1
            new_col = col - 1

        return (new_row, new_col)

    # --------------------------------------------------------------------------
    def __str__(self):
        output = ""
        for row, line in enumerate(self.__diagram):
            output += F"{row:2}: " + " ".join(line) + "\n"

        return(output)

    # --------------------------------------------------------------------------
    # def __repr__(self):
    #     pass

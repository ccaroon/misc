# Encapsulates some Grid logic
class Grid:

    DIRECTIONS = ("N", "NE", "E", "SE", "S", "SW", "W", "NW")

    def __init__(self, rows, cols):
        self.__max_row = rows
        self.__max_col = cols

    def valid_directions(self, row, col):
        valid = {}
        for direction in self.DIRECTIONS:
            valid[direction] = None

            (new_row, new_col) = self.direction_to_col_row(direction, row, col)
            if self.in_bounds(new_row, new_col):
                valid[direction] = (new_row, new_col)

        return valid

    def in_bounds(self, row, col):
        in_bounds = True
        if row < 0 or row >= self.__max_row:
            in_bounds = False

        if col < 0 or col >= self.__max_col:
            in_bounds = False

        return in_bounds

    def direction_to_col_row(self, direction, row, col):
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

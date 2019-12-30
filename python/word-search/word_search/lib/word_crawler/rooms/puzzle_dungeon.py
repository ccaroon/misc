import pyfiglet

from lib.grid import Grid
from .space import Space
# ------------------------------------------------------------------------------
class PuzzleDungeon:
    def __init__(self, puzzle):
        self.__puzzle = puzzle

        self.__location = (0,0)
        self.__rooms = []

        self.__generate_rooms()

    def __generate_rooms(self):
        (rows, cols) = self.__puzzle.size()
        grid = Grid(rows, cols)

        for row in range(rows):
            self.__rooms.append([])
            for col in range(cols):
                letter = self.__puzzle.letter_at(row,col)
                lg_letter = pyfiglet.figlet_format(letter)
                room = Space(
                    F"Puzzle Room - Location[{row},{col}]",
                    lg_letter,
                    # items=[items.lantern],
                    # objects=[
                    #     items.door
                    # ],
                )
                room.location = (row, col)
                self.__rooms[row].append(room)

        # Assign Exits
        for row in range(rows):
            for col in range(cols):
                room = self.__rooms[row][col]
                valid_dirs = grid.valid_directions(row, col)

                if valid_dirs['N']:
                    room.north = self.get_room(valid_dirs['N'][0], valid_dirs['N'][1])
                if valid_dirs['NE']:
                    room.northeast = self.get_room(valid_dirs['NE'][0], valid_dirs['NE'][1])
                if valid_dirs['E']:
                    room.east = self.get_room(valid_dirs['E'][0], valid_dirs['E'][1])
                if valid_dirs['SE']:
                    room.southeast = self.get_room(valid_dirs['SE'][0], valid_dirs['SE'][1])
                if valid_dirs['S']:
                    room.south = self.get_room(valid_dirs['S'][0], valid_dirs['S'][1])
                if valid_dirs['SW']:
                    room.southwest = self.get_room(valid_dirs['SW'][0], valid_dirs['SW'][1])
                if valid_dirs['W']:
                    room.west = self.get_room(valid_dirs['W'][0], valid_dirs['W'][1])
                if valid_dirs['NW']:
                    room.northwest = self.get_room(valid_dirs['NW'][0], valid_dirs['NW'][1])

    def get_room(self, row, col):
        return self.__rooms[row][col]

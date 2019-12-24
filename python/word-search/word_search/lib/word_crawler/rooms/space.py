from adventurelib import Bag, Room

Room.add_direction('northeast', 'southwest')
Room.add_direction('northwest', 'southeast')

class Space(Room):
    # items   - Items in the room that can be picked up.
    # objects - Items in the room that are stationary but can be interacted with:
    #           I.e. doors, windows, floor, carpet, large paintings, etc.
    # NESW    - Exit to another room in that direction.
    def __init__(self, name, desc, items=[], objects=[],
        north=None, northeast=None,
        east=None, southeast=None,
        south=None, southwest=None,
        west=None, northwest=None
    ):
        super().__init__(desc)
        self.name = name

        self.items = Bag()
        for item in items:
            self.items.add(item)

        self.objects = Bag()
        for obj in objects:
            self.objects.add(obj)

        self.north = north
        self.northeast = northeast
        self.east = east
        self.southeast = southeast
        self.south = south
        self.southwest = southwest
        self.west = west
        self.northwest = northwest

        self.enter_scene = None
        self.exit_scene = None

    def __str__(self):
        return F"--- {self.name} ---\n{self.description}"

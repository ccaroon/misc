from adventurelib import Bag, Item
from colorama import Fore, Style

class Object(Item):
    def __init__(self, name, desc, aliases=[], isa=[], state=None, color=Fore.LIGHTBLACK_EX, undroppable=False, real_obj=None):
        super().__init__(name, *aliases)
        self.isa = isa
        self.desc = desc
        self.state = state
        self.color = color
        self.scene = None
        self.real_obj = real_obj
        self.undroppable = undroppable
        self.items = Bag()

    def state_desc(self):
        desc = str(self)
        if self.state:
            desc += F" which is {self.state}"
        return desc

    # Example: object.is_a("door")
    def is_a(self, type_of_thing):
        found = False

        if type_of_thing in self.isa:
            found = True

        return found

    def describe(self):
        if self.scene:
            self.scene.play()

        desc = ""
        if self.desc:
            desc += F"{self.desc} "

        if self.state:
            desc += F"It's {self.state}. "

        for obj in self.items:
            desc += F"The {self} has a {obj} on it."

        return desc

    def __str__(self):
        return F"{self.color}{self.name}{Style.RESET_ALL}"
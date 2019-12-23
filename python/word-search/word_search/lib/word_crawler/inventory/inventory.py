from adventurelib import Bag

class Inventory(Bag):
    def contains_some_sort_of(self, looking_for):
        found = False
        for item in self:
            if looking_for in item.isa:
                found = True
                break

        return found

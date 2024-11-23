from gates.gate import XOR
from gates.gate import AND

class HalfAdder():
    """ HalfAdder Circuit """
    @classmethod
    def operate(cls, x, y):
        """
        Perform HalfAdder Operation on x,y

        Returns:
            Tuple(carry, sum)
        """
        sum = XOR.operate(x,y)
        carry = AND.operate(x,y)

        return (carry, sum)

from gates.gate import Gate

from gates.and_op import AND
from gates.or_op import OR
from gates.not_op import NOT

class XOR(Gate):
    """
    >>> op = XOR(0,0)
    >>> op.result
    0

    >>> op = XOR(0,1)
    >>> op.result
    1

    >>> op = XOR(1,0)
    >>> op.result
    1

    >>> op = XOR(1,1)
    >>> op.result
    0
    """
    def __init__(self, op1, op2):
        self.op1 = op1
        self.op2 = op2


    @property
    def result(self):
        """ (op1 AND !op2) OR (!op1 AND op2) """
        not_op1 = NOT(self.op1)
        not_op2 = NOT(self.op2)

        and1 = AND(self.op1, not_op2.result)
        and2 = AND(not_op1.result, self.op2)

        xor = OR(and1.result, and2.result)

        return xor.result

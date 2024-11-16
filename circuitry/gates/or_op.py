from gates.gate import Gate

class OR(Gate):
    """
    >>> op = OR(0,0)
    >>> op.result
    0

    >>> op = OR(0,1)
    >>> op.result
    1

    >>> op = OR(1,0)
    >>> op.result
    1

    >>> op = OR(1,1)
    >>> op.result
    1
    """
    def __init__(self, op1, op2):
        self.op1 = op1
        self.op2 = op2


    @property
    def result(self):
        return self.op1 | self.op2

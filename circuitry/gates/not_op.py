from gates.gate import Gate

class NOT(Gate):
    """
    >>> op = NOT(0)
    >>> op.result
    1

    >>> op = NOT(1)
    >>> op.result
    0
    """
    def __init__(self, op1):
        self.op1 = op1


    @property
    def result(self):
        return not self.op1

from gates.or_op import OR

class NOR(OR):
    """
    >>> op = NOR(0,0)
    >>> op.result
    1

    >>> op = NOR(0,1)
    >>> op.result
    0

    >>> op = NOR(1,0)
    >>> op.result
    0

    >>> op = NOR(1,1)
    >>> op.result
    0
    """
    def __init__(self, op1, op2):
        super().__init__(op1, op2)


    @property
    def result(self):
        return not super().result

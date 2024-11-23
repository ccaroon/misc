class Gate:
    pass


class AND(Gate):
    """ AND Gate """
    @classmethod
    def operate(cls, op1, op2):
        return op1 & op2


class NAND(AND):
    """ NAND Gate """
    @classmethod
    def operate(cls, op1, op2):
        return not super().operate(op1,op2)


class OR(Gate):
    """ OR Gate """
    @classmethod
    def operate(self, op1, op2):
        return op1 | op2


class NOR(OR):
    """ NOR Gate """
    @classmethod
    def operate(cls, op1, op2):
        return not super().operate(op1, op2)


class NOT(Gate):
    """ NOT Gate """
    @classmethod
    def operate(cls, op1):
        return not op1


class XOR(Gate):
    """
    XOR Gate
    (op1 AND !op2) OR (!op1 AND op2)
    """
    @classmethod
    def operate(cla, op1, op2):
        return OR.operate(
            AND.operate(
                op1,
                NOT.operate(op2)
            ),
            AND.operate(
                NOT.operate(op1),
                op2
            )
        )











#

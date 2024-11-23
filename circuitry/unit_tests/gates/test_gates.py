import unittest

from gates.gate import AND
from gates.gate import NAND
from gates.gate import OR
from gates.gate import NOR
from gates.gate import NOT
from gates.gate import XOR


class TestGates(unittest.TestCase):

    def test_and(self):
        self.assertEqual(AND.operate(0,0), 0)
        self.assertEqual(AND.operate(0,1), 0)
        self.assertEqual(AND.operate(1,0), 0)
        self.assertEqual(AND.operate(1,1), 1)


    def test_nand(self):
        self.assertEqual(NAND.operate(0,0), 1)
        self.assertEqual(NAND.operate(0,1), 1)
        self.assertEqual(NAND.operate(1,0), 1)
        self.assertEqual(NAND.operate(1,1), 0)


    def test_or(self):
        self.assertEqual(OR.operate(0,0), 0)
        self.assertEqual(OR.operate(0,1), 1)
        self.assertEqual(OR.operate(1,0), 1)
        self.assertEqual(OR.operate(1,1), 1)


    def test_nor(self):
        self.assertEqual(NOR.operate(0,0), 1)
        self.assertEqual(NOR.operate(0,1), 0)
        self.assertEqual(NOR.operate(1,0), 0)
        self.assertEqual(NOR.operate(1,1), 0)


    def test_not(self):
        self.assertEqual(NOT.operate(0), 1)
        self.assertEqual(NOT.operate(1), 0)


    def test_xor(self):
        self.assertEqual(XOR.operate(0,0), 0)
        self.assertEqual(XOR.operate(0,1), 1)
        self.assertEqual(XOR.operate(1,0), 1)
        self.assertEqual(XOR.operate(1,1), 0)

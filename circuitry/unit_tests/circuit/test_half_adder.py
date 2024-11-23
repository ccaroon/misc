import unittest

from circuit.half_adder import HalfAdder

class TestHalfAdder(unittest.TestCase):

    def test_truth_table(self):
        self.assertTupleEqual(HalfAdder.operate(0,0), (0,0))
        self.assertTupleEqual(HalfAdder.operate(0,1), (0,1))
        self.assertTupleEqual(HalfAdder.operate(1,0), (0,1))
        self.assertTupleEqual(HalfAdder.operate(1,1), (1,0))

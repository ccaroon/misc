import doctest

import gates.and_op
import gates.or_op
import gates.not_op
import gates.xor_op
import gates.nand_op
import gates.nor_op

def load_tests(loader, tests, ignore):
    tests.addTests(doctest.DocTestSuite(gates.and_op))
    tests.addTests(doctest.DocTestSuite(gates.or_op))
    tests.addTests(doctest.DocTestSuite(gates.not_op))
    tests.addTests(doctest.DocTestSuite(gates.xor_op))
    tests.addTests(doctest.DocTestSuite(gates.nand_op))
    tests.addTests(doctest.DocTestSuite(gates.nor_op))
    # dt_suit = doctest.DocFileSuite(
    #     "and_op.py",
    #     "or_op.py",
    #     package="gates"
    #     # module_relative=True
    # )
    # tests.addTests(dt_suit)

    return tests

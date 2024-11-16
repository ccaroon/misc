from invoke import task


@task
def unit_tests(ctx):
    ctx.run("python -munittest unit_tests/test_gates.py -v")

from invoke import task


@task
def unit_tests(ctx):
    ctx.run("python -m unittest discover -t . -s unit_tests -v")

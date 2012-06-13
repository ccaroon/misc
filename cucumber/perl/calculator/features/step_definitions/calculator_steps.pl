#!/bin/env perl
use strict;

use Calc;

use Test::More;
use Test::BDD::Cucumber::StepFile;
use Method::Signatures; # Allows func($c) {} syntax
################################################################################
Given qr/^the input "([^"]*)"$/, func ($c) {
    $c->stash->{scenario}->{input} = $1;
};

When qr/^the calculator is run$/, func ($c) {
    my $input = $c->stash->{scenario}->{input};
    $c->stash->{scenario}->{output} = Calc->compute($input);
};

Then qr/^the output should be "([^"]*)"$/, func($c) {
    my $output = $c->stash->{scenario}->{output};
    is $output, $1;
};
################################################################################

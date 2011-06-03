#!/bin/env perl
################################################################################
# $Id: $
################################################################################
use strict;
################################################################################
#Any live cell with fewer than two live neighbours dies, as if caused by under-population.
#Any live cell with two or three live neighbours lives on to the next generation.
#Any live cell with more than three live neighbours dies, as if by overcrowding.
#Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
################################################################################
use constant NUM_ROWS = 20;
use constant NUM_COLS = 20;

my @rows;
my @cols;
my @board = [\@rows, @cols];

################################################################################
sub init_board
{
    my $board = shift;
    
    
}
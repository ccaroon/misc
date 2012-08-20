#!/usr/bin/env perl
use strict;
use feature 'switch';

use Cwd 'abs_path';
use File::Basename;
BEGIN
{
    $ENV{MTGDB_CODEBASE} = dirname(abs_path($0)).'/..';
}

use lib "$ENV{MTGDB_CODEBASE}/lib";
use MTGDb::Manager::Cards;
use MTGDb::Manager::Decks;
use MTGDb::Util::Input;
use MTGDb::Util::Output;
################################################################################
my $DONE = 0;
while (!$DONE)
{
    my $input = prompt("MTGDb");

    my ($cmd, $args) = split /\s+/, $input, 2;

    my $target = ($args =~ s/^(card|deck)s?\s*//) ? $1 : 'card';
    my $manager = "MTGDb::Manager::".ucfirst($target).'s';

    given ($cmd)
    {
        when ('exit') {
            $DONE = 1;
        }
        when (undef) {}
        default
        {
            if ($manager->can($cmd))
            {
                print "\n";
                $manager->$cmd($args);
                print "\n";
            }
            else
            {
                msg("$target does not support command: $cmd");
            }
        }
    }
}
################################################################################

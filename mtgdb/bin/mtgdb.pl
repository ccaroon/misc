#!/usr/bin/env perl
use strict;
use feature 'switch';

use Cwd 'abs_path';
use File::Basename;
use Term::ReadLine;

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
my $initial_manager = shift || 'cards';
my $DONE = 0;
my $context = undef;
my $manager = 'MTGDb::Manager::'.ucfirst($initial_manager);

my $term = Term::ReadLine->new('MTGDb');
while (!$DONE)
{
    my $prompt = $manager;
    $prompt =~ s/^MTGDb::Manager:://;
    $prompt .= "($context)" if $context;
    my $input = $term->readline("$prompt:");

    my ($cmd, $args) = split /\s+/, $input, 2;

    #my $target = ($args =~ s/^(card|deck)s?\s*//) ? $1 : 'card';
    #my $manager = "MTGDb::Manager::".ucfirst($target).'s';

    given ($cmd)
    {
        when (undef) {}
        when (/cards|decks/)
        {
            $manager = 'MTGDb::Manager::'.ucfirst($cmd);
            $context = $manager->context();
        }
        when ('exit')
        {
            $DONE = 1;
        }
        default
        {
            if ($manager->can($cmd))
            {
                print "\n";
                $manager->$cmd($args);
                print "\n";
                
                $context = $manager->context();
            }
            else
            {
                msg("$manager does not support command: $cmd");
            }
        }
    }
}
################################################################################

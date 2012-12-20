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
use MTGDb::Manager::Utils;
use MTGDb::Util::Input;
################################################################################
my $initial_manager = shift || 'cards';
my $DONE = 0;
my $manager = 'MTGDb::Manager::'.ucfirst($initial_manager);
################################################################################
my $single_cmd = shift;
if ($single_cmd)
{
    _exec_cmd($manager,$single_cmd,@ARGV);
    exit 0;
}
################################################################################
my $term = Term::ReadLine->new('MTGDb');
while (!$DONE)
{
    my $prompt = $manager->prompt_msg();
    my $input = $term->readline("$prompt:");

    my ($cmd, $args) = split /\s+/, $input, 2;

    given ($cmd)
    {
        when (undef) {}
        when (/cards|decks|utils/)
        {
            if ($args)
            {
                my $tmp_mgr = 'MTGDb::Manager::'.ucfirst($cmd);

                ($cmd, $args) = split /\s+/, $args, 2;
                _exec_cmd($tmp_mgr,$cmd,$args);
            }
            else
            {
                $manager = 'MTGDb::Manager::'.ucfirst($cmd);
            }
        }
        when ('exit')
        {
            $DONE = 1;
        }
        default
        {
            _exec_cmd($manager,$cmd,$args);
        }
    }
}
################################################################################
sub _exec_cmd
{
    my ($mgr, $cmd, $args) = @_;

    if ($mgr->can($cmd))
    {
        print "\n";
        eval
        {
            $mgr->$cmd($args);
        };
        if ($@)
        {
            print STDERR "'$cmd':  $@\n";
        }
        print "\n";
    }
    else
    {
        print "$mgr does not support command: $cmd\n";
    }
}
################################################################################

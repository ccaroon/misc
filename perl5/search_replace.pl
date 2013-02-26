#!/usr/bin/perl
use strict;

use File::Slurp;

my $search  = shift @ARGV;
my $replace = shift @ARGV;

foreach my $file (@ARGV)
{
print "Working $file...\n";
    my @lines = read_file($file);

    my @new_file;
    foreach my $l (@lines)
    {
        if ($l =~ /$search/)
        {
            print "Found: $l\n";
            $l =~ s|$search|$replace|g;
        }
        push @new_file, $l;
    }
    write_file($file, @new_file);
}

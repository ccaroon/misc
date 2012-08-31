#!/usr/bin/perl
use strict;

use File::Slurp;

die "$0 <path> [ext]" unless @ARGV >= 1;

my $path = $ARGV[0];
my $ext  = $ARGV[1];


my @files = read_dir($path);

for my $file (@files)
{
    next unless defined $ext and $file =~ /$ext$/;

    print "*** $file ***\n\n";
    open (IN, "<$path/$file");
    while (<IN>)
    {
        s/e/3/ig;
        s/i/!/ig;
        s/a/@/ig;
        s/o/0/ig;
        s/s/\$/ig;
        s/t/7/ig;

        print;
    }
    close IN;
}

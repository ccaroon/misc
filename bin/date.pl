#!/usr/bin/env perl
use strict;

use Date::Format;
use Date::Parse;

my $cmd = shift;
my $date = shift || time();

if ($cmd =~ /^format/)
{
    my $format = shift ||"%m/%d/%Y %R"; 
    my $val = time2str($format, $date);
    print STDERR "Formatted: [$val]\n";
}
elsif ($cmd =~ /^parse/)
{
    my $val = str2time($date);
    print STDERR "Parsed: [$val]\n";
}
elsif ($cmd =~ /^reformat/)
{
    my $time = str2time($date);
    my $val = time2str("%m/%d/%Y %R", $time);
    print STDERR "Re-Formatted: [$val]\n";
}
else
{
    print STDERR "Unknown command [$cmd]\n";
}

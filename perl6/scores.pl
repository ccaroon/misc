#!/usr/bin/env perl6

use v6;

my $file = open 'scores.dat';
my @names = $file.get.split(' ');

my %matches;
my %sets;

say "List of Names: {@names}\n";

for $file.lines -> $line
{
    my ($pairing, $result) = $line.split(' | ');
    my ($p1, $p2) = $pairing.split(' vs ');
    my ($r1,$r2) = $result.split(':');
    
    %sets{$p1} += $r1;
    %sets{$p2} += $r2;
    
    if ($r1 > $r2)
    {
        %matches{$p1}++;
    }
    else
    {
        %matches{$p2}++;
    }
}

my @sorted = @names.sort({ %sets{$_} }).sort({ %matches{$_} } ).reverse;

for @sorted -> $n
{
    say "$n has won %matches{$n} matches and %sets{$n} sets.";
}
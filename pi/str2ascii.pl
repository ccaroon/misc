#!/usr/bin/env perl
my $str = shift;
my @chars = split //, $str;

my $value = '';
foreach my $c (@chars) {
    $value .= ord($c);
}

print "$value\n";

#!/usr/bin/env perl
##############################################################################
use strict;

use DigitalRoot;
use File::Slurp;

use constant PI => 
    '31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679';
my @PI = split //, PI;
##############################################################################
sub ascii_value {
    my $string = shift;

    my @chars = split //, $string;
    my $value = '';
    foreach my $c (@chars) {
        $value .= ord($c);
    }
    
    return $value;    
}
##############################################################################
sub dr_file {
    my $file = shift;

    my $i = 1;
    my @lines = read_file($file);
    foreach my $line (@lines) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        $line =~ s/\s+/ /g;
        next unless $line;

        my $root;
        if ($line eq 'EOF') {
            $root = "==========================";
            $line = "=========================="
        }
        else {
            my $first_pass = ascii_value($line);
            $root = DigitalRoot->compute($first_pass);            
        }

        my $v = ' ';
        if ($root == $PI[$i-1]) {
            $v = '*'
        }

        print "$i:\t[$v] - $PI[$i-1]/$root - $line\n";
        $i++;
    }    
}
##############################################################################
my $input_file = shift;
die "Usage: $0 <text_file>" unless defined $input_file;

my $mtime = 0;
while (1) {
    my @stats = stat $input_file;
    if ($stats[8] > $mtime) {
        $mtime = $stats[8];
        print "------------------------------------------------------------\n";
        dr_file($input_file);
        print "------------------------------------------------------------\n";
    }
}

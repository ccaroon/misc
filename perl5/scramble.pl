#!/usr/bin/perl
use strict;


# split on \n
# split on space
# preserve orginal form

my $text = join ' ', @ARGV;


my @words = split /\s/, $text;


my $out_text;
foreach my $w (@words)
{
    if (length $w <= 3)
    {
        $out_text .= "$w ";
        next;
    }
    
    $w =~ /(^.)(.*)(.$)/;
    
    my $first  = $1;
    my $middle = $2;
    my $last   = $3;
    
    my $len = length $middle;
    if ($len == 2)
    {
        $middle =~ s/(.)(.)/$2$1/;
        $out_text .= "$first$middle$last ";
    }
    elsif ($len == 3)
    {
        $middle =~ s/(.)(.)(.)/$3$1$2/;
        $out_text .= "$first$middle$last ";
    }
    else
    {
        # move each letter over 1 slot
        
    }
#     print STDERR "$1 -- $2 -- $3\n";
}

print STDERR $out_text,"\n";

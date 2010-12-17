#!/usr/bin/perl
use strict;

use File::Slurp;

die "Usage: $0 out_file <in_file>\n" unless @ARGV >= 1;
my $out_file = shift;
my $in_file  = shift;

my %puzzle;
if ($in_file)
{
    my $row = 1;
    my @lines = read_file($in_file);
    foreach my $l @lines
    {
        my @vals = split /\s+/, $l;
        for (my $c = 1; $c <= 9; $c++)
        {
            $puzzle{$row$c} = $vals[$c-1]
        }
        $row++;
    }
}

# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9
# 1 2 3 4 5 6 7 8 9

print "Difficulty [1=Easy, 2=Medium, 3=Hard]: ";
my $diff = <STDIN>;
chomp $diff;
$diff = "1" unless $diff;

my $id = int(rand 999999);

my $xml =<<EOF;
<?xml version="1.0" ?>
<sudoku id="$id" difficulty="$diff">
EOF

for (my $grid = 1; $grid <= 9; $grid++)
{
    $xml .= "    <grid id='$grid'>\n";
    for (my $cell = 1; $cell <= 9; $cell++)
    {
        $value = _get_value($grid,$cell);
        $xml .= "        <cell id='$cell'>$value</cell>\n";
    }
    $xml .= "    </grid>\n";
}

$xml .=<<EOF;
</sudoku>
EOF

write_file($out_file, $xml);

################################################################################
sub _get_value
{
    my ($grid,$cell) = @_;
    my $value;
    
    if ($in_file)
    {
        $value = $puzzle{"$grid$cell"};
    }
    else
    {
        print "<$grid,$cell>: ";
        $value = <STDIN>;
        chomp $value;
    }
    
    return ($value);
}
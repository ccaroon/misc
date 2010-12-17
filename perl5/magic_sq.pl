package MagicSquare;
################################################################################
# $Id: $
################################################################################
use strict;
use Data::Dumper;
################################################################################
sub new
{
    my $class = shift;
    
    my $this =
    [
        [undef,undef,undef],
        [undef,undef,undef],
        [undef,undef,undef]
    ];
    
    bless $this, $class;
    
    return($this);
}
################################################################################
sub fill
{
    my $this = shift;
    my @digits = @_;

    my $row = 0;
    my $col = 0;
    foreach my $d (@digits)
    {
        $this->[$row]->[$col++] = $d;
        
        if ($col == 3)
        {
            $row++;
            $col = 0;
        }
    }
}
################################################################################
sub compute
{
    my $this = shift;
    
    my %sums;
    
    # rows
    my $i = 1;
    foreach my $row (@$this)
    {
        $sums{"row$i"} = $row->[0] + $row->[1] + $row->[2];
        $i++;
    }
    
    # cols
    my $row = 0;
    for(my $col = 0; $col < 3; $col++)
    {
        $sums{"col".($col+1)}
            = $this->[$row++]->[$col] + $this->[$row++]->[$col] + $this->[$row++]->[$col];
        $row = 0;
    }
    
    # diags
    $sums{diag1} = $this->[0]->[0] + $this->[1]->[1] + $this->[2]->[2];
    $sums{diag2} = $this->[0]->[2] + $this->[1]->[1] + $this->[2]->[0];
    
    return (\%sums);
}
################################################################################
sub check
{
    my $this = shift;
    my %args = @_;
    
    my $is_magical = 1;

    my $sums = $this->compute();
    
    my @values = values %$sums;
    my $target = shift @values;
    
    foreach my $val (@values)
    {
        if ($val != $target)
        {
            $is_magical = 0;
            last;
        }
    }

    if ($args{print})
    {
        $this->print($sums);
        print "===============================\n";
        if($is_magical)
        {
            print "---=== !!!!Eureka!!!! ===---\n";
        }
        else
        {
            print "---=== Sorry! Try Again! ===---\n";
        }
        print "===============================\n\n";
    }

    return($is_magical);
}
################################################################################
sub swap
{
    my $this = shift;
    my ($p1, $p2) = @_;
    
    $p1 =~ s/\s//g;
    my @cell1 = split /,/, $p1, 2;
    
    $p2 =~ s/\s//g;
    my @cell2 = split /,/, $p2, 2;
    
    my $temp = $this->[$cell2[0]]->[$cell2[1]];
    $this->[$cell2[0]]->[$cell2[1]] = $this->[$cell1[0]]->[$cell1[1]];
    
    $this->[$cell1[0]]->[$cell1[1]] = $temp;
}
################################################################################
sub find
{
    my $this = shift;
    my $number = shift;
    
    my @pos;
    
    for (my $r = 0; $r < 3; $r++)
    {
        for (my $c = 0; $c < 3; $c++)
        {
            if ($this->[$r]->[$c]== $number)
            {
                $pos[0] = $r;
                $pos[1] = $c;
                last;
            }
        }
        last if $pos[0];
    }
    
    return (wantarray ? @pos : "$pos[0],$pos[1]");
}
################################################################################
sub print
{
    my $this = shift;
    my $sums = shift;
    
    my $i = 1;
    foreach my $row (@$this)
    {
        print "  -------------\n";
        print "  | $row->[0] | $row->[1] | $row->[2] |";
        print (($sums->{"row$i"}) ? " ".$sums->{"row$i"}."\n" : "\n");
        $i++;
    }
    print "  -------------\n";
    if ($sums->{col1})
    {
        print " / $sums->{col1}  $sums->{col2}  $sums->{col3}  \\\n";
        print "$sums->{diag2}              $sums->{diag1}\n";
    }
}
################################################################################
# Main
################################################################################
my $square = MagicSquare->new();

my @numbers = (8,2,5,1,4,7,6,9,3);
$square->fill(@numbers);
$square->check(print => 1);

my $DONE = 1;
while ($DONE)
{
    print "swap> ";
    my $swap = <STDIN>;
    chomp $swap;
    
    $swap =~ s/\s//g;
    my ($n1, $n2) = split /,/, $swap, 2;
    my $p1 = $square->find($n1);
    my $p2 = $square->find($n2);
    
    $square->swap($p1,$p2);
    $square->check(print => 1);
}
################################################################################
1;
__DATA__


1 = 0,0
2 = 0,1
3 = 0,2

4 = 1,0
5 = 1,1
6 = 1,2

7 = 2,0
8 = 2,1
9 = 2,2

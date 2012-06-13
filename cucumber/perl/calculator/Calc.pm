package Calc;
use strict;
################################################################################
sub compute
{
    my $class = shift;
    my $input = shift;

    die "Missing Input" unless $input;
    
    $input =~ /(\d+)([+\/])(\d+)/;
    
    my $n1 = $1;
    my $op = $2;
    my $n2 = $3;
    
    my $result = undef;
    if ($op eq '+')
    {  
        $result = $n1 + $n2;
    }
    elsif ($op eq '/')
    {
        if ($n2 == 0.0)
        {
            $result = 'Error - Division by Zero!';
        }   
        else
        {
            $result = $n1 / $n2;
            $result = sprintf("%0.1f", $result);
        }
    }

    return($result);
}
################################################################################
1;

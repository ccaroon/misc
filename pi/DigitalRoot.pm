package DigitalRoot;
##############################################################################
use strict;
##############################################################################
sub compute {
    my $class = shift;
    my $num   = shift;

    my $root = 0;
    foreach my $digit (split //, "$num") {
        $root += $digit;
    }

    $root = $class->compute($root) if $root > 9;

    return $root;
}
##############################################################################
if ($0 eq 'DigitalRoot.pm') {
    my $input = shift;
    my $root = DigitalRoot->compute($input);
    print "Root: $root\n";    
}
##############################################################################
1;

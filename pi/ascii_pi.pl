sub digital_root {
    my $num     = shift;
    my $num_str = "$num";

    my $root = 0;
    foreach my $digit (split //, $num_str) {
        $root += $digit;
    }

    $root = digital_root($root) if $root > 9;

    return $root;
}
##############################################################################
foreach my $i (32..126) {
    my $c = chr($i);
    my $dr = digital_root($i);
    print "$c --> $dr\n";
}
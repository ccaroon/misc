package MTGDb::Util::Input;
################################################################################
use strict;

use base 'Exporter';
our @EXPORT = qw(prompt prompt_for_bool prompt_for_val);
################################################################################
sub prompt
{
    my $msg = shift;

    print "$msg: ";
    my $input = <STDIN>;
    chomp $input;

    $input = undef if $input eq '';

    return ($input);
}
################################################################################
sub prompt_for_bool
{
    my $msg = shift;
    
    my $val_str = _prompt_for_val($msg, 'y','n');
    
    return (($val_str eq 'y') ? 1 : 0);
}
################################################################################
sub prompt_for_val
{
    my $msg = shift;
    my @expected_values = @_;

    my $DONE = 0;
    my $val;
    my $val_str = join '|', @expected_values;
    while (!$DONE)
    {
        $val = _prompt("$msg ($val_str)");
        $DONE = (grep /^$val$/, @expected_values) ? 1 :  0;
    }

    return ($val);
}
################################################################################
1;

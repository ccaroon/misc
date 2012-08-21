package MTGDb::Util::Input;
################################################################################
use strict;

use base 'Exporter';
our @EXPORT = qw(prompt prompt_for_bool prompt_for_val prompt_for_num prompt_for_item);
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
sub prompt_for_num
{
    my $msg = shift;
    
    my $DONE = 0;
    my $val;
    while (!$DONE)
    {
        $val = prompt($msg);
        $DONE = ($val =~ /^\d+$/) ? 1 :  0;
    }

    return ($val);
}
################################################################################
sub prompt_for_bool
{
    my $msg = shift;
    
    my $val_str = prompt_for_val($msg, 'y','n');
    
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
        $val = prompt("$msg ($val_str)");
        $DONE = (grep /^$val$/, @expected_values) ? 1 :  0;
    }

    return ($val);
}
################################################################################
sub prompt_for_item
{
    my $msg  = shift;
    my @list = @_;

    my $DONE = 0;

    my $item;
    my $list_str;
    my $num = 1;
    map {$list_str .= "$num) $_\n"; $num++} @list;
    while (!$DONE)
    {
        print $list_str;
        my $i = prompt_for_num($msg);
        $item = $list[$i-1];

        $DONE = (grep /^$item$/, @list) ? 1 :  0;
    }

    return ($item);
}
################################################################################
1;

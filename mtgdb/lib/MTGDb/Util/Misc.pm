package MTGDb::Util::Misc;
################################################################################
use strict;

use base 'Exporter';
our @EXPORT = qw(title_case);
################################################################################
use constant LOWER_WORDS  =>
{
    the  => 1,
    of   => 1,
    a    => 1,
    to   => 1,
    by   => 1,
    from => 1
};
################################################################################
sub title_case
{
    my $str = shift;

    my $new_str = "";
    foreach (split /\s+/, $str)
    {
        my $word = lc $_;

        if ($word =~ s/-/ /g)
        {
            $word = title_case($word);
            $word =~ s/ /-/g
        }
        else
        {
            $word = ucfirst $word unless LOWER_WORDS->{$word};
        }

        $new_str .= "$word ";
    }
    chop $new_str;

    return ($new_str);
}
################################################################################
1;

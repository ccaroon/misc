package MTGDb::Edition;
################################################################################
use strict;

use base 'MTGDb::Base';

use Date::Format;

__PACKAGE__->table('editions');
__PACKAGE__->columns(All       => qw/id name code_name online_code release_date
                                     card_count/);
__PACKAGE__->columns(Stringify => qw/name/);

__PACKAGE__->has_many(cards => 'MTGDb::CardEditionAssoc');
################################################################################
sub recent_editions
{
    my $class = shift;
    
    my $one_year_ago = time - (365 * 86_400);
    my @editions = $class->search_where(
        {
            release_date => {
                '>=', time2str("%Y-%m-d", $one_year_ago),
                '<=', time2str("%Y-%m-d", time)
            }
        },
        {
            order_by => 'release_date'
        }
    );

    return (@editions);
}
################################################################################
1;

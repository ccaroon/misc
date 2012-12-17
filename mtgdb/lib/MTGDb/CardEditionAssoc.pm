package MTGDb::CardEditionAssoc;
################################################################################
use strict;

use base 'MTGDb::Base';

__PACKAGE__->table('card_edition_assoc');
__PACKAGE__->columns(Primary => qw/card_id edition_id card_number/);

__PACKAGE__->has_a(card_id    => 'MTGDb::Card');
__PACKAGE__->has_a(edition_id => 'MTGDb::Edition');
################################################################################
sub card
{
    my $this = shift;
    return($this->card_id());
}
################################################################################
sub edition
{
    my $this = shift;
    return($this->edition_id());
}
################################################################################
1;

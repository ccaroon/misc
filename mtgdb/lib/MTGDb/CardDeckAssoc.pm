package MTGDb::CardDeckAssoc;
################################################################################
use strict;

use base 'Class::DBI';

__PACKAGE__->connection("dbi:SQLite:$ENV{MTGDB_CODEBASE}/db/mtgdb.db");
__PACKAGE__->autoupdate(0);

__PACKAGE__->table('card_deck_assoc');
__PACKAGE__->columns(Primary => qw/card_id deck_id/);
__PACKAGE__->columns(Other   => qw/copies_main copies_side/);

__PACKAGE__->has_a(card_id => 'MTGDb::Card');
__PACKAGE__->has_a(deck_id => 'MTGDb::Deck');
################################################################################
sub card
{
    my $this = shift;
    return($this->card_id());
}
################################################################################
sub deck
{
    my $this = shift;
    return($this->deck_id());
}
################################################################################
1;

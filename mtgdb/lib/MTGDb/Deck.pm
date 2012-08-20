package MTGDb::Deck;
################################################################################
use strict;

use base 'Class::DBI';

__PACKAGE__->connection("dbi:SQLite:$ENV{MTGDB_CODEBASE}/db/mtgdb.db");
__PACKAGE__->autoupdate(0);

__PACKAGE__->table('decks');
__PACKAGE__->columns(All => qw/id name type/);

# TODO: has many cards
################################################################################
use constant DECK_TYPES => (
    'Standard Legal',
    'Legacy',
    'Vintage',
    'Commander'
);
################################################################################
1;

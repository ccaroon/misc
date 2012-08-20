package MTGDb::Deck;
################################################################################
use strict;

use base 'Class::DBI';

__PACKAGE__->connection("dbi:SQLite:$ENV{MTGDB_CODEBASE}/db/mtgdb.db");
__PACKAGE__->autoupdate(0);

__PACKAGE__->table('decks');
__PACKAGE__->columns(All => qw/id name type/);

#__PACKAGE__->has_many(cards => ['MTGDb::CardDeckAssoc' => 'card']);
__PACKAGE__->has_many(cards => 'MTGDb::CardDeckAssoc');
################################################################################
use constant DECK_TYPES => (
    'Standard Legal',
    'Legacy',
    'Vintage',
    'Commander'
);
################################################################################
sub as_hash
{
    my $this = shift;

    my %as_hash;

    my @cols = __PACKAGE__->columns('All');
    foreach my $c (@cols)
    {
        my $name     = $c->name();
        my $accessor = $c->accessor();

        $as_hash{$name} = $this->$accessor();
    }

    return (wantarray ? %as_hash : \%as_hash);
}
################################################################################
1;

package MTGDb::Deck;
################################################################################
use strict;

use base 'MTGDb::Base';

__PACKAGE__->table('decks');
__PACKAGE__->columns(All       => qw/id name type/);
__PACKAGE__->columns(Stringify => qw/name/);

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
1;

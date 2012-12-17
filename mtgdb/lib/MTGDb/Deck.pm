package MTGDb::Deck;
################################################################################
use strict;

use base 'MTGDb::Base';

__PACKAGE__->table('decks');
__PACKAGE__->columns(All       => qw/id name type/);
__PACKAGE__->columns(Stringify => qw/name/);

__PACKAGE__->has_many(cards => 'MTGDb::CardDeckAssoc');
################################################################################
use constant FORMAT_STANDARD => {
    name           => 'Standard',
    min_cards      => 60,
    max_cards      => undef,
    sideboard_size => 15,
    max_copies     => 4,
    legal_editions => [
        'Innistrad',
        'Dark Ascension',
        'Avacyn Restored',
        'M13',
        'Return to Ravnica'
    ],
    has_banned_cards     => 0,
    has_restricted_cards => 0
};

use constant FORMAT_VINTAGE => {
    name           => 'Vintage',
    min_cards      => 60,
    max_cards      => undef,
    sideboard_size => 15,
    max_copies     => 4,
    # All Edition are legal
    legal_editions => undef,
    has_banned_cards     => 1,
    has_restricted_cards => 1
};

use constant FORMAT_LEGACY => {
    name           => 'Legacy',
    min_cards      => 60,
    max_cards      => undef,
    sideboard_size => 15,
    max_copies     => 4,
    # All Edition are legal
    legal_editions => undef,
    has_banned_cards     => 1,
    has_restricted_cards => 0
};

use constant FORMAT_COMMANDER => {
    name           => 'Commander',
    alt_name       => 'Elder Dragon Highlander',
    min_cards      => 100,
    max_cards      => 100,
    sideboard_size => 15,
    max_copies     => 1,
    # All Edition are legal
    legal_editions => undef,
    has_banned_cards     => 0,
    has_restricted_cards => 0
};

use constant FORMATS => {
    FORMAT_STANDARD->{name}  => FORMAT_STANDARD,
    FORMAT_LEGACY->{name}    => FORMAT_LEGACY,
    FORMAT_VINTAGE->{name}   => FORMAT_VINTAGE,
    FORMAT_COMMANDER->{name} => FORMAT_COMMANDER
};

use constant DECK_TYPES => (
    FORMAT_STANDARD->{name},
    FORMAT_VINTAGE->{name},
    FORMAT_LEGACY->{name},
    FORMAT_COMMANDER->{name}
);
################################################################################
1;

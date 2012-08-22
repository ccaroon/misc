package MTGDb::CardDeckAssoc;
################################################################################
use strict;

use base 'MTGDb::Base';

__PACKAGE__->table('card_deck_assoc');
__PACKAGE__->columns(Primary => qw/card_id deck_id/);
__PACKAGE__->columns(Other   => qw/main_copies side_copies/);

__PACKAGE__->has_a(card_id => 'MTGDb::Card');
__PACKAGE__->has_a(deck_id => 'MTGDb::Deck');

__PACKAGE__->set_sql(copies_in_decks
    => "SELECT sum(main_copies+side_copies) FROM __TABLE__ WHERE card_id = ?");
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
sub copies_in_decks
{
    my $class = shift;
    my $card  = shift;

    return ($class->sql_copies_in_decks()->select_val($card->id()));
}
################################################################################
1;

package MTGDb::Manager::Decks;
################################################################################
use strict;
use feature 'switch';

use lib "$ENV{MTGDB_CODEBASE}/lib";
use MTGDb::Card;
use MTGDb::Deck;
use MTGDb::CardDeckAssoc;
use MTGDb::Util::Input;
use MTGDb::Util::Output;
use MTGDb::Util::Misc;

my $CONTEXT = undef;
################################################################################
sub list
{
    my $class = shift;
    
    my $deck_it = MTGDb::Deck->retrieve_all();
    while (my $deck = $deck_it->next())
    {
        msg("* $deck (".$deck->type().")\n");
    }
}
################################################################################
sub add
{
    my $class = shift;
    my $args  = shift;
    
    my ($what,$what_args) = split /\s+/, $args, 2;

    given ($what)
    {
        when ('deck')
        {
            $class->_add_deck($what_args);
        }
        when ('card')
        {
            $class->_add_card($what_args);
        }
        default
        {
            $class->_add_deck($args);
        }
    }
}
################################################################################
sub _add_deck
{
    my $class = shift;
    my $name  = shift;

    $name = prompt("Name") unless $name;
    $name = title_case($name);

    my $deck = MTGDb::Deck->retrieve(name => $name);
    if($deck == undef)
    {
        msg("New Deck: $name\n\n");

        my $type = prompt_for_item("Type", MTGDb::Deck->DECK_TYPES);
        
        $deck = MTGDb::Deck->insert({
            name => $name,
            type => $type
        });
        
        my $msg = $deck
            ? "Successfully add new deck '$name'"
            : "Failed to add new deck.";
        msg($msg);
    }
    else
    {
        msg("Deck named '$name' already exists.");
    }
}
################################################################################
# TODO: don't allow adding non-legal cards to standard legal decks
################################################################################
sub _add_card
{
    my $class = shift;
    my $name  = shift;

    $name = prompt("Card Name") unless $name;
    $name = title_case($name);

    my @cards = MTGDb::Card->search_like(name => "%$name%", { order_by => 'name'});
    my $card;
    if (@cards == 1)
    {
        $card = $cards[0];
    }
    elsif (@cards > 1)
    {
        $card = prompt_for_item("Choose Card", @cards);
    }

    my $deck = $class->_get_deck();

    if ($deck and $card and $card->available_copies())
    {
        my $avail_copies = $card->available_copies();
        msg("\n---=== ".$card->name()." ===---\n");

        my $cda = MTGDb::CardDeckAssoc->retrieve(
            card_id => $card,
            deck_id => $deck,
        );

        my $msg = $cda
            ? "Card '".$card->name()."' already exists in deck. Will update copies."
            : "Adding card '".$card->name()."' to '".$deck->name()."' deck.";
        msg($msg);

        my $main_copies = 0;
        my $side_copies = 0;
        do
        {
            msg("There are $avail_copies of '".$card->name()."' available.");
            $main_copies = prompt_for_num("Main copies");
            $side_copies = prompt_for_num("Sideboard copies");
        }
        while ($main_copies + $side_copies > $avail_copies);

        # Card already exists in deck, update copies
        if ($cda)
        {
            $cda->main_copies($main_copies);
            $cda->side_copies($side_copies);
            
            my $msg = $cda->update() ? "Success!" : "Failed to update deck.";
            msg($msg);
        }
        else
        {
            $cda = $deck->add_to_cards({
                card_id     => $card,
                main_copies => $main_copies,
                side_copies => $side_copies
            });
            
            my $msg = $cda ? 'Success!' : 'Failed to add card to deck.';
            msg($msg);
        }
        $class->_display_deck($deck);
    }
    else
    {
        msg("Card not found: $name") unless $card;
        msg ("No copies available.") if $card and !$card->available_copies();
        msg("Deck not found!")       unless $deck;
    }
}
################################################################################
sub destroy
{
    my $class = shift;
    my $name  = shift;

    $name = prompt("Name") unless $name;
    $name = title_case($name);

    my $deck = MTGDb::Deck->retrieve(name => $name);
    if($deck)
    {
        $deck->delete();
        msg("Destoryed '$name'.");
        $CONTEXT = undef;
    }
    else
    {
        msg("Deck '$name' not found.");
    }
}
################################################################################
sub remove
{
    my $class = shift;
    my $args  = shift;
    
    my ($what,$what_args) = split /\s+/, $args, 2;

    given ($what)
    {
        when ('card')
        {
            $class->_remove_card($what_args);
        }
        default
        {
            msg("Remove what?");
        }
    }
}
################################################################################
sub _remove_card
{
    my $class = shift;
    my $name = shift;

    $name = prompt("Card Name") unless $name;
    $name = title_case($name);
    
    my $card = MTGDb::Card->retrieve(name => $name);
    my $deck = $class->_get_deck();
    
    if ($card and $deck)
    {
        my @cda = $deck->cards(card_id => $card);
        given (scalar @cda)
        {
            when (0)
            {
                msg("'$name' not found in deck.");
            }
            when (1)
            {
                $cda[0]->delete();
                msg("'$name' has been removed from '$deck'.");
            }
            when ($_ > 1)
            {
                msg("Found more than 1 '$name' in deck. Db corrupt?");
            }
        }
    }
    else
    {
        msg("Removal failed.");
    }
}
################################################################################
sub _get_deck
{
    my $class = shift;

    unless ($class->context())
    {
        my $deck_name = prompt("Deck");
        $deck_name = title_case($deck_name);

        my $deck = MTGDb::Deck->retrieve(name => $deck_name);
        if ($deck)
        {
            $class->context($deck);
        }
        else
        {
            msg("Deck not found: $deck_name");
        }
    }

    return ($class->context());
}
################################################################################
sub deck
{
    my $class = shift;
    my $name  = shift;
    
    $name = title_case($name);
    my $deck = MTGDb::Deck->retrieve(name => $name);
    if ($deck)
    {
        $class->context($deck);
        msg("Deck context changed to '$deck'");
    }
    else
    {
        msg("Deck not found: $name");
    }
}
################################################################################
sub show
{
    my $class = shift;
    my $name  = shift;
    
    my $deck;
    if (defined $name)
    {
        $name = title_case($name);
        $deck = MTGDb::Deck->retrieve(name => $name);
    }
    else
    {
        $deck = $class->_get_deck();
    }

    if ($deck)
    {
        $class->_display_deck($deck);
    }
    else
    {
        msg("No deck found with name '$name'");
    }
}
################################################################################
# TODO: min card count for deck type
# TODO: all cards are legal for deck type
################################################################################
sub verify
{
    my $class = shift;
    
    msg("Not Yet Implemented!");
}
################################################################################
# TODO: show cards in order of count
sub _display_deck
{
    my $class = shift;
    my $deck  = shift;

    my $cards_it = $deck->cards();
    my $main_count = 0;
    my $side_count = 0;
    my $main_cards_str = "";
    my $side_cards_str = "";
    while(my $c = $cards_it->next())
    {
        $main_cards_str .= $c->main_copies() ." x " . $c->card->name()."\n"
            if $c->main_copies();
            
        $side_cards_str .= $c->side_copies() ." x " . $c->card->name()."\n"
            if $c->side_copies();

        $main_count += $c->main_copies();
        $side_count += $c->side_copies();
    }
    chomp $main_cards_str;
    chomp $side_cards_str;

    $deck = $deck->as_hash();

    print STDERR <<EOF;
---=== $deck->{name} ===---
$deck->{type}

--- Main Deck ($main_count) ---
$main_cards_str
 
--- Sideboard ($side_count) ---
$side_cards_str

EOF
}
################################################################################
sub context
{
    my $class = shift;
    my $new_val = shift;
    
    if (defined $new_val)
    {
        $CONTEXT = $new_val;
    }

    return ($CONTEXT);
}
################################################################################
sub help
{
    my $class = shift;
    
    print <<EOF;
Deck Manager Commands
---------------------
* add      --> Add a new deck.
* add deck --> Add a new deck.
* add card --> Add a card to a deck.
* deck     --> Set Deck Manager context to a specific deck.
* show     --> Display deck.
* verify   --> Verify a deck.
* help         --> This Message.
EOF
}
################################################################################
1;

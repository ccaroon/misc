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
            #msg("$class 'add' does not support '$what'.");
            $class->_add_deck($args);
        }
    }
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
    }
    else
    {
        msg("Deck not found: $name");
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
        
        if ($deck)
        {
            msg("Successfully add new deck '$name'");
        }
        else
        {
            msg("Failed to add new deck.");
        }
    }
    else
    {
        msg("Deck named '$name' already exists.");
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
        $deck = $class->context();
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
# TODO: don't allow more copies than owned, including copies in other decks
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
        my $num = 1;
        foreach my $c (@cards)
        {
            print "$num) ".$c->name()."\n";
            $num++;
        }
        my $choice = prompt("Choose Card");
        $card = $cards[$choice-1];
    }

    unless ($class->context())
    {
        my $deck_name = prompt("Deck");
        $deck_name = title_case($deck_name);
        my $deck = MTGDb::Deck->retrieve(name => $deck_name);
        $class->context($deck) if $deck;
    }

    my $deck = $class->context();
    if ($deck and $card)
    {
        msg("\n---=== ".$card->name()." ===---\n");
        my $main_copies = prompt_for_num("Copies in Main Deck");
        my $side_copies = prompt_for_num("Copies in Sideboard");

        msg("Adding '".$card->name()."' to '".$deck->name()."' deck.");

        my $cda = MTGDb::CardDeckAssoc->retrieve(
            card_id => $card,
            deck_id => $deck,
        );

        # Card already exists in deck, update copies
        if ($cda)
        {
            $cda->copies_main($main_copies);
            $cda->copies_side($side_copies);
            
            my $msg = $cda->update() ? "Success!" : "Failed to update deck.";
            msg($msg);
        }
        else
        {
            $cda = $deck->add_to_cards({
                card_id     => $card,
                copies_main => $main_copies,
                copies_side => $side_copies
            });
            
            my $msg = $cda ? 'Success!' : 'Failed to add card to deck.';
            msg($msg);
        }
    }
    else
    {
        msg("Card not found: $name") unless $card;
        msg("Deck not found!") unless $deck;
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
        $main_cards_str .= $c->copies_main() ." x " . $c->card->name()."\n"
            if $c->copies_main();
            
        $side_cards_str .= $c->copies_side() ." x " . $c->card->name()."\n"
            if $c->copies_side();

        $main_count += $c->copies_main();
        $side_count += $c->copies_side();
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

package MTGDb::Manager::Decks;
################################################################################
use strict;
use feature 'switch';

use lib "$ENV{MTGDB_CODEBASE}/lib";
use MTGDb::Deck;
use MTGDb::Util::Input;
use MTGDb::Util::Output;
use MTGDb::Util::Misc;
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
        when (undef)
        {
            $class->_add_deck($what_args);
        }
        when ('card')
        {
            $class->_add_card($what_args);
        }
        default
        {
            msg("$class 'add' does not support '$what'.");
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

        my $type = prompt_for_val("Type", MTGDb::Deck->DECK_TYPES);
        
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
    
    $name = title_case($name);
    my $deck = MTGDb::Deck->retrieve(name => $name);
    
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
sub _add_card
{
    my $class = shift;

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
Type: $deck->{type}

==> Main Deck <==
$main_cards_str

$main_count cards
 
==> Sideboard <==
$side_cards_str

$side_count cards
EOF
}
################################################################################
sub test
{
    my $class = shift;

    my $deck = MTGDb::Deck->retrieve(1);
    
    my @cards = $deck->cards();
    foreach my $c (@cards)
    {
        print $c->card->name()."\n";
        print $c->copies_main()."\n";
        print $c->copies_side()."\n";
    }
}
################################################################################
sub help
{
    my $class = shift;
    
    print <<EOF;
Deck Manager Commands
---------------------
* help         --> This Message.
EOF
}
################################################################################
1;

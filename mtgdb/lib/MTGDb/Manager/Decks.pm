package MTGDb::Manager::Decks;
################################################################################
use strict;
use feature 'switch';

use lib "$ENV{MTGDB_CODEBASE}/lib";
use MTGDb::Card;
use MTGDb::Deck;
use MTGDb::CardDeckAssoc;
use MTGDb::Util::Input;
use MTGDb::Util::Misc;

my $CONTEXT = undef;
################################################################################
sub list
{
    my $class = shift;
    
    my $deck_it = MTGDb::Deck->retrieve_all();
    while (my $deck = $deck_it->next())
    {
        print "* $deck (".$deck->type().")\n";
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
            if ($class->context())
            {
                $class->_add_card($args);
            }
            else
            {
                $class->_add_deck($args);
            }
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
        print "New Deck: $name\n\n";

        my $type = prompt_for_item("Type", MTGDb::Deck->DECK_TYPES);
        
        $deck = MTGDb::Deck->insert({
            name => $name,
            type => $type
        });
        
        my $msg = $deck
            ? "Successfully added new deck '$name'\n"
            : "Failed to add new deck.\n";
        print $msg;
    }
    else
    {
        print "Deck named '$name' already exists.\n";
    }
}
################################################################################
# TODO: verify legal number of copies of cards
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

    eval
    {
        die "Deck not found.\n"       unless $deck;
        die "Card not found: $name\n" unless $card;
        die "No copies available.\n"  unless $card->available_copies();

        my $is_legal = $card->legal(format => MTGDb::Deck->FORMATS->{$deck->type()});
        die "'$card' is not legal in a '".$deck->type()."' format deck.\n"
            unless $is_legal;

        my $cda = MTGDb::CardDeckAssoc->retrieve(
            card_id => $card,
            deck_id => $deck,
        );

        print "'$card' already exists in deck. Will update copies.\n\n"
            if $cda;

        my $main_copies = 0;
        my $side_copies = 0;
        my $avail_copies = $card->available_copies();
        do
        {
            print "$card -- $avail_copies available.\n\n";
            $main_copies = prompt_for_num("Main copies");
            $side_copies = prompt_for_num("Sideboard copies");
        }
        while ($main_copies + $side_copies > $avail_copies);

        # Card already exists in deck, update copies
        if ($cda)
        {
            $cda->main_copies($main_copies);
            $cda->side_copies($side_copies);
            
            my $msg = $cda->update()
                ? "Successfully updated '$deck'\n"
                : "Failed to update '$deck'.\n";
            print $msg;
        }
        else
        {
            $cda = $deck->add_to_cards({
                card_id     => $card,
                main_copies => $main_copies,
                side_copies => $side_copies
            });
            
            my $msg = $cda
                ? "Successfully added '$card' to '$deck'\n"
                : "Failed to add '$card' to '$deck'.\n";
            print $msg;
        }

        print "\n";
        $class->_display_deck($deck);
    };
    if ($@)
    {
        print $@;
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
        print "Destoryed '$name'.\n";
        $CONTEXT = undef;
    }
    else
    {
        print "Deck '$name' not found.\n";
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
            print "Remove what?\n";
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
                print "'$name' not found in deck.\n";
            }
            when (1)
            {
                $cda[0]->delete();
                print "'$name' has been removed from '$deck'.\n";
            }
            when ($_ > 1)
            {
                print "Found more than 1 '$name' in deck. Db corrupt?\n";
            }
        }
    }
    else
    {
        print "Removal failed.\n";
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
            print "Deck not found: $deck_name\n";
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
        print "Deck context changed to '$deck'\n";
    }
    else
    {
        print "Deck not found: $name\n";
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
        print "No deck found with name '$name'\n";
    }
}
################################################################################
# TODO: min card count for deck type
# TODO: are all cards are legal for deck type
# TODO: Commander specific stuff like...
#       ...all cards have ONLY commanders colors
################################################################################
sub verify
{
    my $class = shift;
    
    print "Not Yet Implemented!\n";
}
################################################################################
sub _display_deck
{
    my $class = shift;
    my $deck  = shift;

    my $main_count = 0;
    my $side_count = 0;
    my @main_deck;
    my @sideboard;
    my $cards_it = $deck->cards();
    while(my $c = $cards_it->next())
    {
        push @main_deck, {name => $c->card->name(), copies => $c->main_copies()}
            if $c->main_copies();
            
        push @sideboard, {name => $c->card->name(), copies => $c->side_copies()}
            if $c->side_copies();

        $main_count += $c->main_copies();
        $side_count += $c->side_copies();
    }

    $deck = $deck->as_hash();

    print <<EOF;
---=== $deck->{name} ($deck->{type}) ===---

EOF

    print "--- Main Deck ($main_count) ---\n";
    foreach my $c (sort {$a->{copies} <=> $b->{copies}} @main_deck)
    {
        printf "%2d x %s\n", $c->{copies}, $c->{name};
    }

    print "\n--- Sideboard ($side_count) ---\n";
    foreach my $c (sort {$a->{copies} <=> $b->{copies}} @sideboard)
    {
        printf "%2d x %s\n", $c->{copies}, $c->{name};
    }
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
* add         --> Contextually add a deck or a card to a deck.
* add deck    --> Add a new deck.
* add card    --> Add a card to a deck.
* deck        --> Set Deck Manager context to a specific deck.
* destroy     --> Destroy a deck.
* list        --> Display a list of all decks.
* remove card --> Remove a card from a deck.
* show        --> Display deck.
* verify      --> Verify a deck.
* help        --> This Message.
EOF
}
################################################################################
1;

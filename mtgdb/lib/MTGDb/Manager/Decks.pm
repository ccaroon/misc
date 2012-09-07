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

my $DECK = undef;
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
            if ($DECK)
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

        my $main_copies = 0;
        my $side_copies = 0;
        if ($cda)
        {
            $main_copies = $cda->main_copies();
            $side_copies = $cda->side_copies();

            print <<EOF;
'$card' already exists in deck.
* $main_copies x Main
* $side_copies x Sideboard

Will update copies.
EOF
        }
  
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
        if (defined $DECK and $deck->id() == $DECK->id())
        {
            $DECK = undef;
        }

        $deck->delete();
        print "Destoryed '$name'.\n";
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
    my $name  = shift;

    my $deck;
    if ($name)
    {
        $name = title_case($name);
        $deck = MTGDb::Deck->retrieve(name => $name);
    }
    else
    {
        $deck = $DECK;
        unless ($deck)
        {
            $name = prompt("Deck");
            $name = title_case($name);
            $deck = MTGDb::Deck->retrieve(name => $name);
        }
    }

    print "Deck not found: $name\n" unless $deck;

    return ($deck);
}
################################################################################
sub open
{
    my $class = shift;
    my $name  = shift;
    
    $name = title_case($name);
    my $deck = MTGDb::Deck->retrieve(name => $name);
    if ($deck)
    {
        $DECK = $deck;
        print "Opened '$deck' deck.\n";
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

    my $deck = $class->_get_deck($name);
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
# TODO: Commander specific stuff like...
#       ...all cards have ONLY commanders colors
################################################################################
sub verify
{
    my $class = shift;
    my $name  = shift;

    my $deck = $class->_get_deck($name);

    if ($deck)
    {
        print "---=== $deck ===---\n";

        my $format = MTGDb::Deck->FORMATS->{$deck->type()};

        my $cards_it = $deck->cards();
        my $main_count = 0;
        my $side_count = 0;
        while (my $card = $cards_it->next())
        {
            $main_count += $card->main_copies();
            $side_count += $card->side_copies();

            my $count = $card->main_copies() + $card->side_copies();
            print "* Too many copies of '".$card->card()."' in deck.\n"
                if $count > $format->{max_copies}
                    and $card->card()->type() ne MTGDb::Card->TYPE_BASIC_LAND;

            print "* '".$card->card()."' not legal in this deck."
                unless $card->card()->legal(format => $format);
        }

        print "* Too many cards in main deck ($main_count).\n"
            if defined $format->{max_cards} and $main_count > $format->{max_cards};
        print "* Not enough cards in main deck ($main_count).\n"
            if $main_count < $format->{min_cards};

        print "* Sideboard must have exactly $format->{sideboard_size} cards ($side_count).\n"
            if $side_count > 0 and $side_count != $format->{sideboard_size};
    }
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
sub prompt
{
    my $class = shift;

    my $p = "Decks";
    $p .= "($DECK)" if $DECK;

    return ($p);
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
* open        --> Set Deck Manager to operate on a specific deck.
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

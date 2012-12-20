package MTGDb::Manager::Utils;
################################################################################
use strict;

use Data::Dumper;

use lib "$ENV{MTGDB_CODEBASE}/lib";
use MTGDb::Card;
use MTGDb::Deck;
use MTGDb::Edition;
use MTGDb::CardDeckAssoc;
use MTGDb::Util::Input;
use MTGDb::Util::Misc;
################################################################################
sub migrate_editions
{
    my $class = shift;
    
    my %ed_map = (
        M10 => 'Magic 2010',
        M11 => 'Magic 2011',
        M12 => 'Magic 2012',
        M13 => 'Magic 2013',
        DOP => 'Duels of the Planswalkers',
        'PD - Fire and Lightning' => 'Premium Deck Series: Fire and Lightning',
        'Knights vs. Dragons' => 'Duel Decks: Knights vs. Dragons',
    );

    print "** Migrate Editions **\n";
    my @cards = MTGDb::Card->retrieve_all();
    foreach my $c (@cards)
    {
        my @editions = $c->editions__DELETE();
        foreach my $e (@editions)
        {
            my $e_name = $ed_map{$e} || $e;
            my $edition = MTGDb::Edition->retrieve(name => $e_name);
            warn "Edition not found [$e]" and next unless defined $edition;
            
            $edition->add_to_cards({
                card_id => $c->id(),
                card_number => 0
            });
        }
    }
}
################################################################################
sub test
{
    my $class = shift;
    
    my $card = MTGDb::Card->retrieve(name => "Doom Blade");
    print STDERR "=====> Utils.pm #51 --> [$card] \n";
    
    my @e = $card->editions();
map {$_->name()} @e;
print STDERR Dumper \@e;

my $l = $card->latest_edition();
print STDERR Dumper $l;

my $h = $card->as_hash();
print STDERR Dumper $h;
}
################################################################################
sub prompt_msg
{
    my $class = shift;
    return ('Utils');
}
################################################################################
sub help
{
    my $class = shift;
    
    print <<EOF;
Utility Manager Commands
---------------------
* help         --> This Message.
EOF
}
################################################################################
1;

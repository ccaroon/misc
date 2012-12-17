package MTGDb::Card;
################################################################################
use strict;

use base 'MTGDb::Base';

__PACKAGE__->table('cards');
__PACKAGE__->columns(All => qw/id name type sub_type edition_str cost foil
                               rarity count image_name card_text/);
__PACKAGE__->columns(Stringify => qw/name/);

__PACKAGE__->has_many(decks    => 'MTGDb::CardDeckAssoc');
__PACKAGE__->has_many(editions => 'MTGDb::CardEditionAssoc');
################################################################################
use constant CARD_RARITIES => (
'Common',
'Uncommon',
'Rare',
'Mythic Rare'
);

use constant TYPE_BASIC_LAND => 'Basic Land';

use constant CARD_TYPES => (
TYPE_BASIC_LAND,
'Creature',
'Instant',
'Sorcery',
'Land',
'Artifact',
'Artifact Creature',
'Legendary Creature',
'Enchantment',
'Planeswalker'
);
################################################################################
sub legal
{
    my $this = shift;
    my %args = @_;
    
    my $format = $args{format} || MTGDb::Deck->FORMAT_STANDARD;

    my $is_legal = 0;    
    if ($format->{legal_editions} == undef)
    {
        $is_legal = 1;
    }
    else
    {
        foreach my $e ($this->editions())
        {
            $is_legal = grep /^$e$/, @{$format->{legal_editions}};
            last if $is_legal;
        }
    }

    return($is_legal);
}
################################################################################
sub editionsX
{
    my $this         = shift;
    my @add_editions = @_;

    if (@add_editions)
    {
        my $edition_str = $this->edition_str();
        foreach my $e (@add_editions)
        {
            $edition_str .= "|$e";
        }
        $this->edition_str($edition_str);
    }

    my @editions = split /\|/, $this->edition_str();

    return (wantarray ? @editions : \@editions);
}
################################################################################
sub latest_edition
{
    my $this = shift;

    my @editions = $this->editions();
    return(pop @editions);
}
################################################################################
sub available_copies
{
    my $this = shift;
    return($this->count() - MTGDb::CardDeckAssoc->copies_in_decks($this));
}
################################################################################
1;

package MTGDb::Card;
################################################################################
use strict;

use base 'Class::DBI';

__PACKAGE__->connection("dbi:SQLite:$ENV{MTGDB_CODEBASE}/db/mtgdb.db");
__PACKAGE__->autoupdate(0);

__PACKAGE__->table('cards');
# Changing the column names may require changes to mtgdb.pl
# * add_card
# * export_csv
# * ...???...
__PACKAGE__->columns(All => qw/id name type sub_type editions cost legal foil
                               rarity count image_name/);
################################################################################
use constant STANDARD_LEGAL_EDITIONS => (
'Scars of Mirrodin',
'Mirrodin Besieged',
'New Phyrexia',
'M12',
'Innistrad',
'Dark Ascension',
'Avacyn Restored',
'M13'
);

use constant RECENT_EDITIONS => (
'M12',
'Innistrad',
'Dark Ascension',
'Avacyn Restored',
'M13'
);

use constant CARD_RARITIES => (
'Common',
'Uncommon',
'Rare',
'Mythic Rare'
);

use constant CARD_TYPES => (
'Basic Land',
'Creature',
'Instant',
'Sorcery',
'Land',
'Artifact',
'Legendary Creature',
'Enchantment'
);
################################################################################
sub as_hash
{
    my $this = shift;

    my %card_as_hash;

    my @cols = __PACKAGE__->columns('All');
    foreach my $c (@cols)
    {
        my $name     = $c->name();
        my $accessor = $c->accessor();

        $card_as_hash{$name} = $this->$accessor();
    }

    return (wantarray ? %card_as_hash : \%card_as_hash);
}
################################################################################
sub as_csv
{
    my $this = shift;
    my %args = @_;

    my @cols = defined $args{cols} ? @{$args{cols}} : __PACKAGE__->columns('All');
    my $card_as_csv = "";

    foreach my $c (@cols)
    {
        $card_as_csv .= $this->$c().',';
    }
    chop $card_as_csv;

    return ($card_as_csv);
}
################################################################################
1;

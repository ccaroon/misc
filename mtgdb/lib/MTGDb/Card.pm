package MTGDb::Card;
################################################################################
use strict;

use base 'Class::DBI';

__PACKAGE__->connection("dbi:CSV:", undef, undef, {
    f_ext => '.csv',
    f_dir => $ENV{MTGDB_CODEBASE}.'/db'
});

__PACKAGE__->autoupdate(0);

__PACKAGE__->table('cards');
__PACKAGE__->columns(Primary => qw/name/);
# NOTE: These have to be 'Essential' to work with DBD::CSV b/c lazy loading
#       does not work.
__PACKAGE__->columns(Essential => qw/type subtype edition cost legal foil rarity count image imagename/);
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
        $card_as_hash{$c} = $this->$c();
    }

    return (wantarray ? %card_as_hash : \%card_as_hash);
}
################################################################################
1;

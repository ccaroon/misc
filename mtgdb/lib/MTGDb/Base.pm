package MTGDb::Base;
################################################################################
use strict;

use base 'Class::DBI';

__PACKAGE__->connection("dbi:SQLite:$ENV{MTGDB_CODEBASE}/db/mtgdb.db");
__PACKAGE__->autoupdate(0);
################################################################################
sub as_hash
{
    my $this = shift;

    my %as_hash;

    my @cols = $this->columns('All');
    foreach my $c (@cols)
    {
        my $name     = $c->name();
        my $accessor = $c->accessor();

        $as_hash{$name} = $this->$accessor();
    }

    return (wantarray ? %as_hash : \%as_hash);
}
################################################################################
1;

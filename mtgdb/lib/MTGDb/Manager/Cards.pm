package MTGDb::Manager::Cards;
################################################################################
use strict;
use feature 'switch';

use DBI;
use File::Basename;
use File::Slurp;
use LWP::UserAgent;

use lib "$ENV{MTGDB_CODEBASE}/lib";
use MTGDb::Card;
use MTGDb::CardDeckAssoc;
use MTGDb::Util::Input;
use MTGDb::Util::Output;
use MTGDb::Util::Misc;

use constant BASE_SYNC_IP =>'192.168';
use constant SYNC_PORT    => 8080;

my $UA  = LWP::UserAgent->new();
my $LAST_IMAGE_FETCH_TIME = time;
my %EDITION_MAP = (
    'Avacyn Restored'     => 'avr',
    'Dark Ascension'      => 'dka',
    'Rise of the Eldrazi' => 'eldrazi',
    'Mirrodin Besieged'   => 'besieged',
    'Scars of Mirrodin'   => 'scars',
    'Alara Reborn'        => 'reborn',
    'Shards of Alara'     => 'shards',
    'Seventh Edition'     => 'seventh',
    'New Phyrexia'        => 'new',
    'DOP'                 => 'duels',
    'Knights vs. Dragons' => 'knights',
    'Ravnica: City of Guilds' => 'ravnica',
    'PD - Fire and Lightning' => 'pd2',
    'Planechase 2012'         => 'pc2',
    'Unglued'                 => 'ug',
);
################################################################################
sub add
{
    my $class = shift;
    my $name  = shift;

    $name = prompt("Name") unless $name;
    $name = title_case($name);

    my $card = MTGDb::Card->retrieve(name => $name);

    if ($card)
    {
        $class->_display(card => $card);
        
        my $add_edition = prompt_for_item("Add Edition",
            MTGDb::Card->RECENT_EDITIONS, undef);
        my $is_foil     = prompt_for_bool("Is Foil");
        my $add_copies  = prompt("Add # Copies");

        print "\n<---------------------------------------------->\n\n";

        # Editions and Legality
        my @editions = split /\|/, $card->editions;
        push @editions, $add_edition if defined $add_edition;
        my $is_legal = $class->_is_legal(editions => \@editions);

        print "Adding '$add_edition' to Editions.\n" if defined $add_edition;

        my $legal_status = ($is_legal) ? "Legal" : "Not Legal";
        print "Card is now $legal_status.\n" if $is_legal != $card->legal;

        # Foil - Assumes won't change from True to False only from False to True
        if ($is_foil)
        {
            print "Setting Foil Status to Yes.\n";
        }
        else
        {
            $is_foil = $card->foil();
        }

        # Copies
        print "Adding $add_copies copies.\n" if defined $add_copies;

        print "\n";

        my $ok = prompt_for_bool("Confirm");
        if ($ok)
        {
            $card->editions(join '|', @editions) if defined $add_edition;
            $card->legal($is_legal);
            $card->foil($is_foil);
            $card->count($card->count() + $add_copies) if $add_copies;

            my $cnt = $card->update();
            if ($cnt > 0)
            {
                msg("Updated '".$card->name."'.");
            }
            else
            {
                msg("Failed to update '".$card->name."'.");
            }
        }
        else
        {
            msg("Discarding changes to '".$card->{name}."'!");
        }
    }
    else
    {
        msg("New Card: '$name'\n\n");

        my $card_data            = {id => undef, name => $name};
        $card_data->{cost}       = uc(prompt("Mana Cost"));
        $card_data->{type}       = prompt_for_item("Type", MTGDb::Card->CARD_TYPES);
        $card_data->{sub_type}   = prompt("Subtype");
        $card_data->{editions}   = prompt_for_item("Edition", MTGDb::Card->RECENT_EDITIONS);
        $card_data->{legal}      = $class->_is_legal(editions => [$card_data->{editions}]);
        $card_data->{rarity}     = prompt_for_item("Rarity", MTGDb::Card->CARD_RARITIES);
        $card_data->{foil}       = prompt_for_bool("Foil");
        $card_data->{count}      = prompt("Count");

        $card_data->{image_name}  = $class->_image_name(card_name => $card_data->{name});

        $class->_display(card_data => $card_data);

        my $ok = prompt_for_bool("Confirm");
        if ($ok)
        {
            my $card = MTGDb::Card->insert($card_data);
            if ($card)
            {
                msg("Successfully added new card '".$card->name."'.");
            }
            else
            {
                msg("Failed to add new card.");
            }
        }
        else
        {
            msg("Add cancelled.");
        }
    }
    
    return;
}
################################################################################
# TODO: show which decks the card is in
################################################################################
sub show
{
    my $class = shift;
    my $name  = shift;

    $name = prompt("Name") unless $name;
    $name = title_case($name);

    my $card = MTGDb::Card->retrieve(name => $name);

    if ($card)
    {
        $class->_display(card => $card);
    }
    else
    {
        msg("No card found with name '$name'");
    }
    
    return;
}
################################################################################
sub search
{
    my $class = shift;
    my $args  = shift;

    my ($field, $term) = split /\s+/, $args, 2;

    unless (defined $term)
    {
        $term = $field;
        $field = 'name';
    }

    $term = title_case($term);

    my @cards = MTGDb::Card->search_like($field => "%$term%", { order_by => 'name'});
    foreach my $card (@cards)
    {
        $class->_display(card => $card, format => 'summary');
    }
    msg("\nSearch for '$term' found ".scalar(@cards)." records.");
    
    return;
}
################################################################################
sub _fetch_image
{
    my $class = shift;
    my %args = @_;

    my $found = 0;
    my $card_name     = $args{name};
    my $card_type     = $args{type}     || '';
    my $card_edition  = $args{edition}  || '';
    my $img_dir       = "$ENV{MTGDB_CODEBASE}/images";

    my $image_name = $args{image_name};
    unless ($image_name)
    {
        $image_name = lc($card_name);
        $image_name =~ s/\s+/_/g;
        $image_name =~ s/[',]//g;
        $image_name .= '.jpg';
    }

    my $url = "http://magiccards.info/query?q=$card_name";
    $url .= "+e%3A$card_edition" if $card_edition and $card_type ne 'Scheme';

    my $response = $UA->get($url);
    die "[".$response->status_line()."] Request failed for '$card_name'"
        if $response->is_error();

    my $regex;
    my $img_url;
    given ($card_type)
    {
        when ('Scheme')
        {
            $img_url = "http://magiccards.info/extras/scheme/archenemy";
            $regex = qr|<img src="http://magiccards.info/extras/scheme/archenemy/(.*)\.jpg"\s+alt="Scheme - Archenemy - ([^"]+)"|;
        }
        default
        {
            $img_url = "http://magiccards.info/scans";
            $regex = qr|<img src="http://magiccards.info/scans/(.*)\.jpg"\s+alt="([^"]+)"|;
        }
    }

    my $html = $response->content();
    while ($html =~ s|$regex||)
    {
        my $img_path = $1;
        my $name     = $2;

        if (lc ($name) eq lc($card_name))
        {
            $found = 1;

            # Fetch Image
            unless ($args{dry_run})
            {
                msg("Fetching '$card_name' as '$image_name'.\n");

                my $response = $UA->get("$img_url/$img_path.jpg",
                    ':content_file' => "$img_dir/$image_name");

                die "[".$response->status_line()."] Failed to fetch image '$image_name'"
                    if $response->is_error();
            }

            last;
        }
    }

    msg("Card not found: [$card_name]\n") unless $found;
}
################################################################################
sub fetch_images
{
    my $class = shift;
    my %args = (@_ == 1) ? split /\s+/, $_[0] : @_;

    $LAST_IMAGE_FETCH_TIME = time-1;

    my $dry_run = $args{dry_run} || 0;

    my $card_it = MTGDb::Card->retrieve_all();

    while(my $card = $card_it->next())
    {
        next if -f "$ENV{MTGDB_CODEBASE}/images/".$card->image_name;
    
        my @editions = split /\|/, $card->editions();
        my $card_edition = pop @editions;
        $card_edition =~ s/^\s+//;
        $card_edition =~ s/\s+$//;
        $card_edition = $EDITION_MAP{$card_edition} || $card_edition;

        eval
        {
            $class->_fetch_image(
                name       => $card->name,
                type       => $card->type,
                edition    => $card_edition,
                image_name => $card->image_name,
                dry_run    => $dry_run
            );
        };
        if ($@)
        {
            msg($@);
        }
    }
    
    return;
}
################################################################################
sub count
{
    my $class = shift;

    my $card_it = MTGDb::Card->retrieve_all();

    my $unique_cards = 0;
    my $total_cards  = 0;
    while(my $card = $card_it->next())
    {
        $unique_cards++;
        $total_cards += $card->count;
    }

    msg("Unique Cards: $unique_cards");
    msg("Total Cards: $total_cards");
    
    return;
}
################################################################################
sub check_dups
{
    my $class = shift;

    my $card_it = MTGDb::Card->retrieve_all();
    
    my %dups;
    while (my $card = $card_it->next())
    {
        $dups{lc($card->name)}++;
    }

    map
    {
        msg("Duplicate Card Found: [$_] ($dups{$_})\n")
            if $dups{$_} > 1;
    } keys %dups;
    
    return;
}
################################################################################
sub recalc_legal
{
    my $class = shift;
    
    my $card_it = MTGDb::Card->retrieve_all();
    while (my $card = $card_it->next())
    {
        my @editions = split /\|/, $card->editions();

        my $old_legal = $card->legal();
        my $new_legal = $class->_is_legal(editions => \@editions);

        if ($new_legal != $old_legal)
        {
            my $legal_str = $new_legal ? 'Now Legal' : 'No Longer Legal';
            msg("'".$card->name."' is $legal_str");

            $card->legal($new_legal);
            $card->update();
        }
    }
    
    return;
}
################################################################################
sub import_csv
{
    my $class = shift;
    my $file  = shift;

    if (defined $file)
    {
        my $path = dirname($file);
        my $name = basename($file);
        my $dbh = DBI->connect("dbi:CSV:", undef, undef, {
            f_dir => $path,
            f_ext => '.csv',
        });

        msg("Importing. Please wait...");

        my $stmt = $dbh->prepare("select * from $name");
        $stmt->execute();

        while (my $row = $stmt->fetchrow_hashref())
        {
            delete $row->{image};
            MTGDb::Card->insert($row);
        }
        $stmt->finish();
    }
    else
    {
        msg("Missing filename argument. Usage: import /path/to/file.csv");
    }
    
    return;
}
################################################################################
sub export_csv
{
    my $class = shift;
    my $file  = shift;

    if (defined $file)
    {
        my $path = dirname($file);
        my $name = basename($file);
        my $dbh = DBI->connect("dbi:CSV:", undef, undef, {
            f_dir => $path,
            f_ext => '.csv',
        });

        my $total_cards = MTGDb::Card->count_all();
        msg("Exporting $total_cards cards. Please wait...");

        # Create CSV "table" whose name is $name
        # Types don't matter to DBD::CSV
        # Order needs to match order of HanDbase cols
        $dbh->do(<<EOF);
create table $name (
    name       varchar(256),
    type       varchar(256),
    sub_type   varchar(256),
    editions   varchar(256),
    cost       varchar(256),
    legal      integer,
    foil       integer,
    rarity     varchar(256),
    count      integer,
    image      varchar(256),
    image_name varchar(256)
)
EOF

        # Export cards
        my $card_it    = MTGDb::Card->retrieve_all();
        my $insert_sql = "insert into $name values (?,?,?,?,?,?,?,?,?,null,?)";
        my $stmt = $dbh->prepare($insert_sql);
        my $count = 0;
        while (my $card = $card_it->next())
        {
            my @values = map {$card->$_()} qw(name type sub_type editions cost legal foil rarity count image_name);
            $stmt->execute(@values);

            $count++;
            print "$count/$total_cards\r";
        }
        $stmt->finish();
    }
    else
    {
        msg("Missing filename argument. Usage: export /path/to/file.csv");
    }
    
    return;
}
################################################################################
sub _is_legal
{
    my $class = shift;
    my %args = @_;

    my $editions = $args{editions};

    my $is_legal = 0;
    foreach my $e (@$editions)
    {
        $is_legal = grep /^$e$/, MTGDb::Card->STANDARD_LEGAL_EDITIONS;
        last if $is_legal;
    }

    return($is_legal);
}
################################################################################
sub _image_name
{
    my $class = shift;
    my %args = @_;

    my $image_name = lc $args{card_name};
    $image_name =~ s/\s/_/g;
    $image_name =~ s/[^A-Za-z0-9\-_]//g;

    return ($image_name . ".jpg")
}
################################################################################
sub _display
{
    my $class = shift;
    my %args = @_;

    my $format    = $args{format};
    my $card      = $args{card};
    my $card_data = defined $card ? $card->as_hash() : $args{card_data};

    if (lc $format eq 'summary')
    {
        print <<EOF;
---=== $card_data->{name} ($card_data->{cost}) ===---
EOF
    }
    else
    {
        print <<EOF;
--=== $card_data->{name} ($card_data->{cost}) ===--
$card_data->{type} -- $card_data->{sub_type} -- $card_data->{rarity}

Editions: $card_data->{editions}
Legal:    $card_data->{legal}
Foil:     $card_data->{foil}
Image:    $card_data->{image_name}
Copies:   $card_data->{count}
EOF

        if ($card)
        {
            my @decks = $card->decks();
            print "\n-- Decks --\n" if @decks;
            foreach my $d (@decks)
            {
                my $total_copies = $d->main_copies() + $d->side_copies();
                print "* ".$d->deck()->name()." (x$total_copies)\n";
            }
            
            my $avail_copies = $card->available_copies();
            print "\nAvailable Copies: $avail_copies\n";
        }
    }
}
################################################################################
sub sync
{
    my $class = shift;
    my $args  = shift;
    
    my ($what, $ip) = split /\s+/, $args, 2;

    given ($ip)
    {
        when (/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        {
            $ip .= ':'.SYNC_PORT;
        }
        when (/\d{1,3}\.\d{1,3}/)
        {
            $ip = BASE_SYNC_IP.".$ip:".SYNC_PORT;
        }
        default
        {
            $ip = undef;
            msg("IP [$ip] does not look valid.");
        }
    }

    if (defined $ip)
    {
        $class->_sync_db(host => $ip)     if $what eq 'db';
        $class->_sync_images(host => $ip) if $what eq 'images';
    }
    
    return;
}
################################################################################
sub verify
{
    my $class = shift;
    
    $class->check_dups();
    $class->fetch_images(dry_run => 1);
    
    return;
}
################################################################################
sub _sync_db
{
    my $class = shift;
    my %args = @_;

    my $host = $args{host};
    my $file = "$ENV{MTGDB_CODEBASE}/export.csv";
    $class->export_csv($file);

    msg("Syncing Db to host @ $host...\n");
    my $response = $UA->post(
        "http://$host/applet_add.html",
        {
            localfile => [$file],
            appletname => "Magic Cards" #TODO: don't hard-code DB name
        },
        'Content_Type' => 'form-data'
    );

    msg("Error syncing db: [".$response->status_line()."]")
        if $response->is_error();

    unlink $file if -f $file;
}
################################################################################
sub _sync_images
{
    my $class = shift;
    my %args = @_;

    my $host = $args{host};

    my $img_path = "$ENV{MTGDB_CODEBASE}/images";

    my @files = read_dir($img_path);
    @files = sort @files;
    foreach my $image_name (@files)
    {
        next unless $image_name =~ /\.jpg$/;

        my @stats = stat "$img_path/$image_name";
        #9 == mtime
        if ($stats[9] > $LAST_IMAGE_FETCH_TIME)
        {
            msg("Syncing '$image_name' to host @ $host...\n");
            my $response = $UA->post(
                "http://$host/applet_add.html",
                {
                    localfile => ["$img_path/$image_name"],
                    UpPDB     => 'Add File'
                },
                'Content_Type' => 'multipart/form-data'
            );
            msg("Error uploading image '$image_name': [".$response->status_line()."]")
                if $response->is_error();
        }
    }
}
################################################################################
sub context
{
    my $class = shift;
    return (undef);
}
################################################################################
sub help
{
    my $class = shift;
    
    print <<EOF;
Card Manager Commands
---------------------
* add          --> Add a new card.
* show         --> Show a card by name.
* search       --> Search for a card by any field. Defaults to name.
                   search Doom Blade
                   search name Doom Blade
                   search type Creature
* fetch_images --> Fetch images.
* check_dups   --> Check for duplicates in the database.
* verify_db    --> Check for dups and verify card with magiccards.info
* recalc_legal --> Recalculate the legalness of each card.
* import_csv   --> Import records from a CSV file into the Card database.
                   import /path/to/file.csv
* export_csv   --> Export database to a CSV file.
                   export /path/to/output.csv
* count        --> Count unique cards and total cards.
* sync         --> Sync DB and images to HanDBase.
                   sync <db|images> <IP>
* help         --> This Message.
EOF

    return;
}
################################################################################
1;

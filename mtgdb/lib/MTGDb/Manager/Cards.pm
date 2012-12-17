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
use MTGDb::Deck;
use MTGDb::Edition;
use MTGDb::CardDeckAssoc;
use MTGDb::Util::Input;
use MTGDb::Util::Misc;

use constant IMAGE_DIR => "$ENV{MTGDB_CODEBASE}/images";
use constant BASE_SYNC_IP =>'192.168';
use constant SYNC_PORT    => 8080;

my $UA  = LWP::UserAgent->new();
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

        # Remove existing editions from edition choices
        my @editions = $card->editions();
        my @edition_choices;
        foreach my $e (MTGDb::Edition->recent_editions())
        {
            push @edition_choices, $e unless grep /^$e$/, @editions;
        }
        my $add_edition = prompt_for_item("Add Edition",
            undef, @edition_choices);

        my $is_foil     = prompt_for_bool("Is Foil");
        my $add_copies  = prompt("Add # Copies");

        print "\n<---------------------------------------------->\n\n";

        # Editions
        print "Adding '$add_edition' to Editions.\n" if defined $add_edition;

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
        print "Adding $add_copies copies.\n\n" if defined $add_copies;

        my $ok = prompt_for_bool("Confirm");
        if ($ok)
        {
            $card->editions($add_edition) if $add_edition;
            $card->foil($is_foil);
            $card->count($card->count() + $add_copies) if $add_copies;

            my $cnt = $card->update();
            if ($cnt > 0)
            {
                print "Updated '".$card->name."'.\n";
            }
            else
            {
                print "Failed to update '".$card->name."'.\n";
            }
        }
        else
        {
            print "Discarding changes to '".$card->{name}."'!\n";
        }
    }
    else
    {
        print "New Card: '$name'\n\n";

        my $card_data            = {id => undef, name => $name};
        $card_data->{cost}       = uc(prompt("Mana Cost"));
        $card_data->{type}       = prompt_for_item("Type", MTGDb::Card->CARD_TYPES);
        $card_data->{sub_type}   = prompt("Subtype");
        $card_data->{edition_str}
            = prompt_for_item("Edition", MTGDb::Edition->recent_editions());
        $card_data->{rarity}
            = prompt_for_item("Rarity", MTGDb::Card->CARD_RARITIES);
        $card_data->{foil}       = prompt_for_bool("Foil");
        $card_data->{count}      = prompt("Count");
        $card_data->{image_name} = $class->_image_name(card_name => $card_data->{name});

        $class->_display(card_data => $card_data);

        my $ok = prompt_for_bool("Confirm");
        if ($ok)
        {
            my $card = MTGDb::Card->insert($card_data);
            if ($card)
            {
                $class->_verify_card(card => $card);
                print "Successfully added new card '$card'.\n";
            }
            else
            {
                print "Failed to add new card.\n";
            }
        }
        else
        {
            print "Add cancelled.\n";
        }
    }
}
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
        print "No card found with name '$name'\n";
    }
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
    print "\nSearch for '$term' found ".scalar(@cards)." records.\n";
}
################################################################################
sub _fetch_card_info
{
    my $class = shift;
    my %args = @_;

    my $card = $args{card};
    my $name = $card->name();
    my $edition = $card->latest_edition();
    $edition = $EDITION_MAP{$edition} || $edition;

    # NOTE: !$name means match full name
    my $url = "http://magiccards.info/query?q=!$name";
    # NOTE: !$name and edition (e:ED) do not work together.
    #$url .= "+e%3A$edition" if $edition;
    my $response = $UA->get($url);
    die "[".$response->status_line()."] Request failed for '$name'\n"
        if $response->is_error();

    my $html = $response->content();

    my %info;
    # Image URL
    my $base_img_url = "http://magiccards.info/scans";
    my $img_regex = qr|<img src="http://magiccards.info/scans/(.*)\.jpg"\s+alt="([^"]+)"|;
    while($html =~ s|$img_regex||)
    {
        my $img_name = $1;
        my $alt_txt  = $2;

        if (lc ($alt_txt) eq lc($name))
        {
            $info{image_url} = "$base_img_url/$img_name.jpg";
            last;
        }
    }

    # Type, Subtype, Mana Cost, Card Text & Flavor Text
    if ($html =~ m|<p>(.*)</p>\s*<p class="ctext"><b>(.*?)</b></p>\s+<p><i>(.*?)</i></p>|s)
    {
        my $type_str = $1;
        my $ctext    = $2;
        my $ftext    = $3;

        $type_str =~ s/\n//g;
        my ($type_info, $mana_cost) = split /,/, $type_str, 2;

        # Type & Subtype
        my ($type, $sub_type) = split /—/, $type_info, 2;
        $type =~ s/^\s+//;
        $type =~ s/\s+$//;
        $type =~ s|\s+[0-9*]+/[0-9*]+$||; #strip off power/toughness
        $info{type} = $type;
        
        $sub_type =~ s/^\s+//;
        $sub_type =~ s/\s+$//;
        $sub_type =~ s|\s+[0-9*]+/[0-9*]+$||; #strip off power/toughness
        $info{sub_type} = $sub_type;

        # Mana Cost
        $mana_cost =~ s/^\s+//;
        $mana_cost =~ s/\s+$//;
        my ($cost, $converted_cost) = split /\s+/, $mana_cost, 2;

        $info{mana_cost} = $cost;

        $converted_cost =~ s#(\(|\))##g;
        $info{converted_mana_cost} = $converted_cost || $cost;

        # Card Text
        $info{card_text} = '';
        if ($ctext)
        {
            $info{card_text} = $ctext;
            $info{card_text} =~ s|<br>|\n|g;
        }
        
        # Flavor Text
        $info{flavor_text} = '';
        if ($ftext)
        {
            $info{flavor_text} = $ftext;
            $info{flavor_text} =~ s|<br>|\n|g;
        }
    }
    else
    {
        $info{card_text} = undef;
    }

    return (wantarray ? %info : \%info);
}
################################################################################
sub _fetch_image
{
    my $class = shift;
    my %args = @_;

    print "Fetching $args{img_url}...";

    my $response = $UA->get($args{img_url},
        ':content_file' => IMAGE_DIR."/$args{img_name}");

    if ($response->is_success())
    {
        print "Success!\n";
    }
    else
    {
        print "Failed: ".$response->status_line()."\n";
    }
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

    print "Unique Cards: $unique_cards\n";
    print "Total Cards: $total_cards\n";
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
        print "Duplicate Card Found: [$_] ($dups{$_})\n"
            if $dups{$_} > 1;
    } keys %dups;
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

        print "Importing. Please wait...\n";

        my $stmt = $dbh->prepare("select * from $name");
        $stmt->execute();

        while (my $row = $stmt->fetchrow_hashref())
        {
            delete $row->{legal};
            delete $row->{image};
            MTGDb::Card->insert($row);
        }
        $stmt->finish();
    }
    else
    {
        print "Missing filename argument. Usage: import /path/to/file.csv\n";
    }
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
        print "Exporting $total_cards cards. Please wait...\n";

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
            my @values = map {$card->$_()} qw(name type sub_type edition_str cost legal foil rarity count image_name);
            $stmt->execute(@values);

            $count++;
            print "$count/$total_cards\r";
        }
        $stmt->finish();
    }
    else
    {
        print "Missing filename argument. Usage: export /path/to/file.csv\n";
    }
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

Editions: $card_data->{edition_str}
Foil:     $card_data->{foil}
Image:    $card_data->{image_name}
Copies:   $card_data->{count}

[$card_data->{card_text}]
EOF

        if ($card)
        {
            # Legality
            print "\n-- Legal Formats --\n";
            foreach my $name (MTGDb::Deck->DECK_TYPES())
            {
                print "* $name\n"
                    if $card->legal(format => MTGDb::Deck->FORMATS->{$name});
            }

            # Decks
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
            print "IP [$ip] does not look valid.\n";
        }
    }

    if (defined $ip)
    {
        $class->_sync_db(host => $ip)     if $what eq 'db';
        $class->_sync_images(host => $ip) if $what eq 'images';
    }
}
################################################################################
sub fetch_info
{
    my $class = shift;

    print "Please wait...\n";

    my $card_it = MTGDb::Card->retrieve_all();
    while(my $card = $card_it->next())
    {
        my $img_path = IMAGE_DIR."/".$card->image_name();

        next if $card->type() eq 'Scheme';
        next if $card->card_text() and -f $img_path;

        my $info = $class->_fetch_card_info(card => $card);

        if($info->{image_url})
        {
            $class->_fetch_image(
                img_url => $info->{image_url},
                img_name => $card->image_name()
            ) unless -f $img_path;
        }
        else
        {
            print "'$card' -- Unable to determine image URL.\n";
        }

        if (!defined $info->{card_text})
        {
            print "'$card' -- Unable to determine card text.\n";
        }
        elsif ($info->{card_text} ne '')
        {
            $card->card_text($info->{card_text});
            $card->update()
                ? print "Updated text for '$card'.\n"
                : print "Failed to update text for '$card'.\n";
        }
    }
}
################################################################################
sub verify
{
    my $class = shift;
    my $args  = shift;
    
    my ($what,$what_args) = split /\s+/, $args, 2;

    given ($what)
    {
        when ('db')
        {
            $class->_verify_db($what_args);
        }
        when ('card')
        {
            $class->_verify_card(card_name => $what_args);
        }
        default
        {
            $class->_verify_card(card_name => $args);
            #print STDERR "Usage: verify <card|db> [card name]\n";
        }
    }
}
################################################################################
sub _verify_card
{
    my $class = shift;
    my %args = @_;

    my $card = $args{card};
    unless ($card)
    {
        die "Missing argument 'card_name'\n"
            unless defined $args{card_name};

        my $name = title_case($args{card_name});
        $card = MTGDb::Card->retrieve(name => $name);
        die "Card not found: $name\n" unless $card;
    }

    eval
    {
        my $info = $class->_fetch_card_info(card => $card);
    
        print "---=== $card ===---\n";
        if ($card->type() ne $info->{type})
        {
            print "* Type mismatch [".$card->type()."] != [$info->{type}]\n";
            my $update = prompt_for_bool("Update Type to '$info->{type}'");
            $card->type($info->{type}) if $update;
        }
    
        if ($card->sub_type() ne $info->{sub_type})
        {
            print "* Subtype mismatch [".$card->sub_type()."] != [$info->{sub_type}]\n";
            my $update = prompt_for_bool("Update Subtype to '$info->{sub_type}'");
            $card->sub_type($info->{sub_type}) if $update;
        }
    
        if ($card->cost() ne $info->{mana_cost})
        {
            print "* Mana cost mismatch [".$card->cost()."] != [$info->{mana_cost}]\n";
            my $update = prompt_for_bool("Update Mana Cost to '$info->{mana_cost}'");
            $card->cost($info->{mana_cost}) if $update;
        }
    
        $card->update();
    };
    if ($@)
    {
        print "Could not fetch card info for $card: $@\n";
    }
}
################################################################################
sub _verify_db
{
    my $class = shift;
    my $args  = shift;

    my $card_it = MTGDb::Card->retrieve_all();
    while(my $card = $card_it->next())
    {
        next if $card->type() eq 'Scheme';

        $class->_verify_card(card => $card);
    }
}
################################################################################
sub _sync_db
{
    my $class = shift;
    my %args = @_;

    my $host = $args{host};
    my $file = "$ENV{MTGDB_CODEBASE}/export.csv";
    $class->export_csv($file);

    print "Syncing Db to host @ $host...\n";
    my $response = $UA->post(
        "http://$host/applet_add.html",
        {
            localfile => [$file],
            appletname => "Magic Cards" #TODO: don't hard-code DB name
        },
        'Content_Type' => 'form-data'
    );

    print "Error syncing db: [".$response->status_line()."]\n"
        if $response->is_error();

    unlink $file if -f $file;
}
################################################################################
sub _sync_images
{
    my $class = shift;
    my %args = @_;

    my $host = $args{host};

    my $img_path = IMAGE_DIR;

    my @files = read_dir($img_path);
    @files = sort @files;
    foreach my $image_name (@files)
    {
        next unless $image_name =~ /\.jpg$/;

        my @stats = stat "$img_path/$image_name";
        #9 == mtime
        if ($stats[9] > time() - (30 * 60))
        {
            print "Syncing '$image_name' to host @ $host...\n";
            my $response = $UA->post(
                "http://$host/applet_add.html",
                {
                    localfile => ["$img_path/$image_name"],
                    UpPDB     => 'Add File'
                },
                'Content_Type' => 'multipart/form-data'
            );
            print "Error uploading image '$image_name': [".$response->status_line()."]\n"
                if $response->is_error();
        }
    }
}
################################################################################
sub prompt_msg
{
    my $class = shift;
    return ('Cards');
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
* fetch_info   --> Fetch images and card text.
* check_dups   --> Check for duplicates in the database.
* verify       --> Verify single card or db
                   verify card Card Name
                   verify Card Name
                   verify db
* import_csv   --> Import records from a CSV file into the Card database.
                   import_csv /path/to/file.csv
* export_csv   --> Export database to a CSV file.
                   export_csv /path/to/output.csv
* count        --> Count unique cards and total cards.
* sync         --> Sync DB and images to HanDBase.
                   sync <db|images> <IP>
* help         --> This Message.
EOF
}
################################################################################
1;

#!/usr/bin/env perl
use strict;

use feature 'switch';

use Cwd 'abs_path';
use File::Basename;
use File::Slurp;
use LWP::UserAgent;

BEGIN
{
    $ENV{MTGDB_CODEBASE} = dirname(abs_path($0)).'/..';
}

use lib "$ENV{MTGDB_CODEBASE}/lib";
use MTGDb::Card;

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
sub add_card
{
    my %args = @_;
    my $name = $args{name};

    $name = _prompt("Name") unless $name;
    
    my $card = MTGDb::Card->retrieve($name);

    if ($card)
    {
        _display_card(card => $card);
        
        my $add_edition = _prompt_for_val("Add Edition",
            MTGDb::Card->RECENT_EDITIONS, undef);
        my $is_foil     = _prompt_for_bool("Is Foil");
        my $add_copies  = _prompt("Add # Copies");

        print "\n<---------------------------------------------->\n\n";

        # Editions and Legality
        my @editions = split /,/, $card->editions;
        push @editions, $add_edition if defined $add_edition;
        my $is_legal = _is_legal(editions => \@editions);

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

        my $ok = _prompt_for_bool("Confirm");
        if ($ok)
        {
            $card->editions(join ',', @editions) if defined $add_edition;
            $card->legal($is_legal);
            $card->foil($is_foil);
            $card->count($card->count() + $add_copies) if $add_copies;

            my $cnt = $card->update();
            if ($cnt > 0)
            {
                _msg("Updated '".$card->name."'.");
            }
            else
            {
                _msg("Failed to update '".$card->name."'.");
            }
        }
        else
        {
            _msg("Discarding changes to '".$card->{name}."'!");
        }
    }
    else
    {
        _msg("Adding new card with name '$name'");

        my $card_data = {name => $name};
        $card_data->{cost}       = uc(_prompt("Mana Cost"));
        $card_data->{type}       = _prompt_for_val("Type", MTGDb::Card->CARD_TYPES);
        $card_data->{subtype}    = _prompt("Subtype");
        $card_data->{editions}    = _prompt_for_val("Edition", MTGDb::Card->RECENT_EDITIONS);
        $card_data->{legal}      = _is_legal(editions => [$card_data->{editions}]);
        $card_data->{rarity}     = _prompt_for_val("Rarity", MTGDb::Card->CARD_RARITIES);
        $card_data->{foil}       = _prompt_for_bool("Foil");
        $card_data->{count}      = _prompt("Count");

        $card_data->{imagename}  = _image_name(card_name => $card_data->{name});

        _display_card(card_data => $card_data);

        my $ok = _prompt_for_bool("Confirm");
        if ($ok)
        {
            my $card = MTGDb::Card->insert($card_data);
            if ($card)
            {
                _msg("Successfully added new card '".$card->name."'.");
            }
            else
            {
                _msg("Failed to add new card.");
            }
        }
        else
        {
            _msg("Add cancelled.");
        }
    }
}
################################################################################
sub show_card
{
    my %args = @_;
    my $name = $args{name};

    $name = _prompt("Name") unless $name;

    my $card = MTGDb::Card->retrieve($name);

    if ($card)
    {
        _display_card(card => $card);
    }
    else
    {
        _msg("No card found with name '$name'");
    }
}
################################################################################
sub search_card
{
    my %args = @_;
    my $field = $args{field};
    my $term  = $args{term};
    
    unless (defined $term)
    {
        $term = $field;
        $field = 'name';
    }
    
    my @cards = MTGDb::Card->search_like($field => "%$term%");
    foreach my $card (@cards)
    {
        _display_card(card => $card, format => 'summary');
    }
    _msg("\nFound ".scalar(@cards)." records.");
}
################################################################################
sub _fetch_image
{
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
                _msg("Fetching '$card_name' as '$image_name'.\n");

                my $response = $UA->get("$img_url/$img_path.jpg",
                    ':content_file' => "$img_dir/$image_name");

                die "[".$response->status_line()."] Failed to fetch image '$image_name'"
                    if $response->is_error();
            }

            last;
        }
    }

    _msg("Card not found: [$card_name]\n") unless $found;
}
###############################################################################
sub fetch_images
{
    my %args = @_;
    my $dry_run = $args{dry_run} || 0;

    my $card_it = MTGDb::Card->retrieve_all();

    while(my $card = $card_it->next())
    {
        next if -f "$ENV{MTGDB_CODEBASE}/images/".$card->imagename;
    
        my @editions = split ',', $card->editions();
        my $card_edition = pop @editions;
        $card_edition =~ s/^\s+//;
        $card_edition =~ s/\s+$//;
        $card_edition = $EDITION_MAP{$card_edition} || $card_edition;

        eval
        {
            _fetch_image(
                name       => $card->name,
                type       => $card->type,
                edition    => $card_edition,
                image_name => $card->imagename,
                dry_run    => $dry_run
            );
        };
        if ($@)
        {
            _msg($@);
        }
    }
}
################################################################################
sub count_cards
{
    my $card_it = MTGDb::Card->retrieve_all();

    my $unique_cards = 0;
    my $total_cards  = 0;
    while(my $card = $card_it->next())
    {
        $unique_cards++;
        $total_cards += $card->count;
    }

    _msg("Unique Cards: $unique_cards");
    _msg("Total Cards: $total_cards");
}
################################################################################
sub check_dups
{
    my $card_it = MTGDb::Card->retrieve_all();
    
    my %dups;
    while (my $card = $card_it->next())
    {
        $dups{lc($card->name)}++;
    }

    map
    {
        _msg("Duplicate Card Found: [$_] ($dups{$_})\n")
            if $dups{$_} > 1;
    } keys %dups;
}
################################################################################
sub recalc_legal
{
    my $this = shift;
    
    my $card_it = MTGDb::Card->retrieve_all();
    while (my $card = $card_it->next())
    {
        my @editions = split /,/, $card->editions();

        my $old_legal = $card->legal();
        my $new_legal = _is_legal(editions => \@editions);

        if ($new_legal != $old_legal)
        {
            my $legal_str = $new_legal ? 'Now Legal' : 'No Longer Legal';
            _msg("'".$card->name."' is $legal_str");

            $card->legal($new_legal);
            $card->update();
        }
    }
}
################################################################################
sub _is_legal
{
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
    my %args = @_;
    
    my $image_name = lc $args{card_name};
    $image_name =~ s/\s/_/g;
    $image_name =~ s/[^A-Za-z0-9\-_]//g;
    #$image_name =~ s/[',\/]//g;
    #$image_name =~ s/\)//g;
    #$image_name =~ s/\(//g;
  
    return ($image_name . ".jpg")
}
#################################################################################
sub sync
{
    my %args = @_;
    my $ip = $args{ip};

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
            _msg("IP [$ip] does not look valid.");
        }
    }

    if (defined $ip)
    {
        _sync_db(host => $ip)     if $args{what} eq 'db';
        _sync_images(host => $ip) if $args{what} eq 'images';
    }
}
#################################################################################
sub _sync_db
{
    my %args = @_;

    my $host = $args{host};
    my $file = "$ENV{MTGDB_CODEBASE}/db/cards.csv";

    _msg("Syncing Db to host @ $host...\n");
    my $response = $UA->post(
        "http://$host/applet_add.html",
        {
            localfile => [$file],
            appletname => "Magic Cards" #TODO: don't hard-code DB name
        },
        'Content_Type' => 'form-data'
    );

    _msg("Error syncing db: [".$response->status_line()."]")
        if $response->is_error();    
}
#################################################################################
sub _sync_images
{
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
            _msg("Syncing '$image_name' to host @ $host...\n");
            my $response = $UA->post(
                "http://$host/applet_add.html",
                {
                    localfile => ["$img_path/$image_name"],
                    UpPDB     => 'Add File'
                },
                'Content_Type' => 'multipart/form-data'
            );
            _msg("Error uploading image '$image_name': [".$response->status_line()."]")
                if $response->is_error();
        }
    }
}
################################################################################
sub _display_card
{
    my %args = @_;

    my $format = $args{format};
    my $card   = (defined $args{card}) ? $args{card}->as_hash() : $args{card_data};

    if (lc $format eq 'summary')
    {
        print <<EOF;
--=== $card->{name} ($card->{cost}) ===---
EOF
    }
    else
    {
        print <<EOF;

--=== $card->{name} ($card->{cost}) ===--
$card->{type} -- $card->{subtype} -- $card->{rarity}

Editions: $card->{editions}
Legal:    $card->{legal}
Foil:     $card->{foil}
Image:    $card->{imagename}
Copies:   $card->{count}

EOF
    }
}
################################################################################
sub _prompt
{
    my $msg = shift;

    print "$msg: ";
    my $input = <STDIN>;
    chomp $input;

    $input = undef if $input eq '';

    return ($input);
}
################################################################################
sub _prompt_for_bool
{
    my $msg = shift;
    
    my $val_str = _prompt_for_val($msg, 'y','n');
    
    return (($val_str eq 'y') ? 1 : 0);
}
################################################################################
sub _prompt_for_val
{
    my $msg = shift;
    my @expected_values = @_;

    my $DONE = 0;
    my $val;
    my $val_str = join '|', @expected_values;
    while (!$DONE)
    {
        $val = _prompt("$msg ($val_str)");
        $DONE = (grep /^$val$/, @expected_values) ? 1 :  0;
    }

    return ($val);
}
################################################################################
sub _msg
{
    my $msg = shift;

    $msg .= "\n" unless $msg =~ m|\n$|;
    print $msg;
}
################################################################################
# TODO: command to "sell/trade" a card, i.e. decrement count
################################################################################
my $DONE = 0;
while (!$DONE)
{
    my $input = _prompt("\nmtg_db");

    my ($cmd, $args) = split /\s+/, $input, 2;
    print "\n";

    given ($cmd)
    {
        when ('add')
        {
            add_card(name => $args);
        }
        when (/^(show|view)$/)
        {
            show_card(name => $args);
        }
        when ('search')
        {
            my ($field, $term) = split /\s+/, $args, 2;
            search_card(field => $field, term => $term);
        }
        when ('fetch_images')
        {
            $LAST_IMAGE_FETCH_TIME = time-1;
            fetch_images();
        }
        when ('check_dups')
        {
            check_dups();
        }
        when ('verify_db')
        {
            check_dups();
            fetch_images(dry_run => 1);
        }
        when ('recalc_legal')
        {
            recalc_legal();
        }
        when ('count')
        {
            count_cards();
        }
        when ('sync')
        {
            my ($what, $ip) = split /\s+/, $args, 2;
            sync(what => $what, ip => $ip);
        }
        when ('help') {
            print <<EOF;
Commands:
    * add          --> Add a new card.
    * show         --> Show a card by name.
    * view         --> Alias for 'show'
    * search       --> Search for a card by any field. Defaults to name.
                       search Doom Blade
                       search name Doom Blade
                       search type Creature
    * fetch_images --> Fetch images.
    * check_dups   --> Check for duplicates in the database.
    * verify_db    --> Check for dups and verify card with magiccards.info
    * recalc_legal --> Recalculate the legalness of each card.
    * count        --> Count unique cards and total cards.
    * sync         --> Sync DB and images to HanDBase.
                       sync <db|images> <IP>
    * help         --> This Message.
EOF
        }
        when ('exit') {
            $DONE = 1;
        }
        default
        {
            _msg("Unknown command [$cmd].\n");
        }
    }
}

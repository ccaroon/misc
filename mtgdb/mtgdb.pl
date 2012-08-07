#!/usr/bin/env perl
use strict;

use feature 'switch';

use DBI;
use File::Slurp;
use LWP::UserAgent;

use constant DB_NAME      => 'mtg_db.csv';
use constant BASE_SYNC_IP =>'192.168';
use constant SYNC_PORT    => 8080;

my $UA  = LWP::UserAgent->new();

use constant STANDARD_LEGAL_EDITIONS => qw(
Scars of Mirrodin
Mirrodin Besieged
New Phyrexia
M12
Innistrad
Dark Ascension
Avacyn Restored
M13
);

my $DBH = DBI->connect ("dbi:CSV:", {f_ext=>'csv'})
    or die "Cannot connect: $DBI::errstr";

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

my $DONE = 0;
while (!$DONE)
{
    my $input = _prompt("mtg_db> ");

    my ($cmd, $args) = split /\s+/, $input, 2;

    given ($cmd)
    {
        when ('add')
        {
            add_card(name => $args);
        }
        when ('show')
        {
            show_card(name => $args);
        }
        when ('search')
        {
            search_card(name => $args);
        }
        when ('fetch_images_db')
        {
            fetch_images_db();
        }
        when ('check_dups')
        {
            check_dups();
        }
        when ('verify_db')
        {
            check_dups();
            fetch_images_db(dry_run => 1);
        }
        when ('count')
        {
            count_cards();
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
################################################################################
#if ($SYNC)
#{
#    given ($SYNC)
#    {
#        when (/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
#        {
#            $SYNC .= ':'.SYNC_PORT;
#        }
#        when (/\d{1,3}\.\d{1,3}/)
#        {
#            $SYNC = BASE_SYNC_IP.".$SYNC:".SYNC_PORT;
#        }
#        default
#        {
#            die "IP [$SYNC] does not look valid.";
#        }
#    }
#
#    sync();
#}
################################################################################
sub add_card
{
    my %args = @_;
    my $name = $args{name};

    $name = _prompt("Name: ") unless $name;
    
    my $stmt = $DBH->prepare("select * from ".DB_NAME." where Name = ?");
    $stmt->execute($name);
    my $card = $stmt->fetchrow_hashref();
    $stmt->finish();

    if ($card)
    {
        _display_card($card);
        
        my $add_edition = _prompt("Add Edition: ");
        my $is_foil     = _prompt("Is Foil: ");
        my $add_copies  = _prompt("Add X Copies: ");

        print "\n<---------------------------------------------->\n\n";

        # Recompute Legality
        my @editions = split /,/, $card->{Edition};
        push @editions, $add_edition if defined $add_edition;
        my $is_legal = _is_legal(editions => \@editions);

        print "Adding '$add_edition' to Editions.\n" if defined $add_edition;

        my $legal_status = ($is_legal) ? "Legal" : "Not Legal";
        print "Card is now $legal_status.\n" if $is_legal != $card->{Legal};

        my $foil_status = (defined $is_foil and $is_foil) ? "Yes" : "No";
        print "Changing Foil Status to $foil_status.\n" if defined $is_foil;
        
        print "Adding $add_copies copies.\n" if defined $add_copies;

        my $ok = _prompt_for_val("\nConfirm (y|n)? ", 'y', 'n');
        if ($ok eq 'y' )
        {
            _msg("Updated '$card->{name}'.");
        }
        else
        {
            _msg("Discarding changes to '$card->{name}'!");
        }
    }
    else
    {
        _msg("Adding new card with name '$name'");
        
    }
}
################################################################################
sub show_card
{
    my %args = @_;
    my $name = $args{name};

    $name = _prompt("Name: ") unless $name;
    
    my $stmt = $DBH->prepare("select * from ".DB_NAME." where Name = ?");
    $stmt->execute($name);
    my $card = $stmt->fetchrow_hashref();
    $stmt->finish();

    if ($card)
    {
        _display_card($card);
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
    my $name = $args{name};

    $name = _prompt("Name: ") unless $name;

    my $stmt = $DBH->prepare("select * from ".DB_NAME." where Name clike ?");
    $stmt->execute("%$name%");

    while (my $card = $stmt->fetchrow_hashref())
    {
        _display_card($card);
    }
    $stmt->finish();
}
################################################################################
sub _fetch_image
{
    my %args = @_;
    my $found = 0;
    my $card_name     = $args{name};
    my $card_type     = $args{type}     || '';
    my $card_edition  = $args{edition}  || '';

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
                    ':content_file' => $image_name);

                die "[".$response->status_line()."] Failed to fetch image '$image_name'"
                    if $response->is_error();
            }

            last;
        }
    }

    _msg("Card not found: [$card_name]\n") unless $found;
}
###############################################################################
sub fetch_images_db
{
    my %args = @_;
    my $dry_run = $args{dry_run} || 0;

    my $stmt = $DBH->prepare("select Name,Type,Edition,ImageName from ".DB_NAME);
    $stmt->execute();

    while (my $row = $stmt->fetchrow_hashref())
    {
        next if -f $row->{ImageName};
    
        my @editions = split ',', $row->{Edition};
        my $card_edition = pop @editions;
        $card_edition =~ s/^\s+//;
        $card_edition =~ s/\s+$//;
        $card_edition = $EDITION_MAP{$card_edition} || $card_edition;

        eval
        {
            _fetch_image(
                name       => $row->{Name},
                type       => $row->{Type},
                edition    => $card_edition,
                image_name => $row->{ImageName},
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
    my $stmt = $DBH->prepare("select Count from ".DB_NAME);
    $stmt->execute();

    my $unique_cards = 0;
    my $total_cards  = 0;
    while (my $row = $stmt->fetchrow_hashref())
    {
        $unique_cards++;
        $total_cards += $row->{Count};
    }

    _msg("Unique Cards: $unique_cards");
    _msg("Total Cards: $total_cards");
}
################################################################################
sub check_dups
{   
    my $stmt = $DBH->prepare("select Name from ".DB_NAME);
    $stmt->execute();
    
    my %dups;
    while (my $row = $stmt->fetchrow_hashref())
    {
        $dups{lc($row->{Name})}++;
    }

    map
    {
        _msg("Duplicate Card Found: [$_] ($dups{$_})\n")
            if $dups{$_} > 1;
    } keys %dups;
}
################################################################################
sub _is_legal
{
    my %args = @_;
    my $editions = $args{editions};

    my $is_legal = 0;
    foreach my $e (@$editions)
    {
        $is_legal = grep /^$e$/, STANDARD_LEGAL_EDITIONS;
        last if $is_legal;
    }

    return($is_legal);
}
#################################################################################
#sub sync
#{
#    my %args = @_;
#
#    sync_db() if $CMD eq 'fetch_images_db';
#    sync_images();
#}
#################################################################################
#sub sync_db
#{
#    my %args = @_;
#    
#    _msg("Syncing $NAME to HanDBase...\n");
#    my $response = $UA->post(
#        "http://$SYNC/applet_add.html",
#        {
#            localfile => [$NAME],
#            appletname => "Magic Cards" #TODO: don't hard-code DB name
#        },
#        'Content_Type' => 'form-data'
#    );
#
#    _msg("[".$response->status_line()."] Error uploading DB to HanDBase: $NAME")
#        if $response->is_msgor();    
#}
#################################################################################
#sub sync_images
#{
#    my %args = @_;
#
#    my @files = read_dir('.');
#    @files = sort @files;
#    foreach my $image_name (@files)
#    {
#        next unless $image_name =~ /\.jpg$/;
#
#        my @stats = stat $image_name;
#        #9 == mtime
#        if ($stats[9] > $START_TIME)
#        {
#            _msg("Syncing '$image_name' to HanDBase @ $SYNC...\n");
#            my $response = $UA->post(
#                "http://$SYNC/applet_add.html",
#                {
#                    localfile => [$image_name],
#                    UpPDB     => 'Add File'
#                },
#                'Content_Type' => 'multipart/form-data'
#            );
#            _msg("[".$response->status_line()."] Error uploading image to HanDBase '$image_name'")
#                if $response->is_msgor();
#        }
#    }
#}
################################################################################
sub _display_card
{
    my $card = shift;
    
    print <<EOF;
<---------------------------------------------->
--=== $card->{name} ($card->{cost}) ===---
$card->{type} -- $card->{subtype} -- $card->{rarity}
$card->{edition}

Legal: $card->{legal} | Foil: $card->{foil}

$card->{count} copies
<---------------------------------------------->
EOF
}
################################################################################
sub _prompt
{
    my $msg = shift;

    print "$msg";
    my $input = <STDIN>;
    chomp $input;

    $input = undef if $input eq '';

    return ($input);
}
################################################################################
sub _prompt_for_val
{
    my $msg = shift;
    my @expected_values = @_;

    my $DONE = 0;
    my $val;
    while (!$DONE)
    {
        $val = _prompt($msg);
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
#function name2image_name(name) {
#  name = name.toLowerCase();
#  name = name.replace(/\s+/g,'_');
#  name = name.replace(/[',\/]/g, '');
#  name = name.replace(/\)/g, '');
#  name = name.replace(/\(/g, '');
#  
#  return (name + ".jpg")
#}
################################################################################

#!/usr/bin/env perl
use strict;

use feature 'switch';
use utf8;

use Data::Dumper;
use DBI;
use File::Slurp;
use Getopt::Long;
use LWP::UserAgent;

use constant BASE_SYNC_IP =>'192.168';
use constant SYNC_PORT => 8080;

# This has to happen before GetOptions is called.
my $CMD = shift;

my $UA  = LWP::UserAgent->new();

my $NAME;
my $SYNC;
my $CARD_TYPE;
my $SILENT;
my $DEBUG;
GetOptions(
    "name=s"      => \$NAME,
    "sync=s"      => \$SYNC,
    "card_type=s" => \$CARD_TYPE,
    'silent'      => \$SILENT,
    'debug'       => \$DEBUG,
);
die <<EOF unless ($CMD);
Usage: $0 CMD --name <CSV DB | Card Name> --sync <AAA.BBB.CCC.DDD | CCC.DDD > --card_type <special card type>

Commands:
    - fetch_image: Fetch the image for a single card.
    - fetch_images_db: Fetch images for all cards in CSV database.
    - check_dups: Check CSV database for duplicate cards based on card name.
    - verify_db: check_dups() and verify cards exists in online db.

Options:
    - name: Used to specify Card Name or CSV database name
    - card_type: Used to specify special card types, e.g. 'Scheme'
    - sync: Specify that you want to sync to HanDBase. Value indicates IP address.
EOF

################################################################################
my $START_TIME = time() - 1;

given ($CMD)
{
    when ('fetch_image')
    {
        die "fetch_image: Missing required param 'name', e.g. --name 'Card Name'.\n"
            unless $NAME;
            
        $CARD_TYPE ||= '';
        fetch_image(card_name => $NAME, card_type => $CARD_TYPE);
    }
    when ('fetch_images_db')
    {
        die "fetch_image_db: Missing required param 'name', e.g. --name card_database_name.csv.\n"
            unless $NAME;
        fetch_images_db(db => $NAME);
    }
    when ('check_dups')
    {
        die "check_dups: Missing required param 'name', e.g. --name card_database_name.csv.\n"
            unless $NAME;
        check_dups(db => $NAME);
    }
    when ('verify_db')
    {
        die "verify_db: Missing required param 'name', e.g. --name card_database_name.csv.\n"
            unless $NAME;
        check_dups(db => $NAME);
        fetch_images_db(db => $NAME, dry_run => 1);
    }
    default
    {
        die "Unknown command [$CMD].\n";
    }
}

if ($SYNC)
{
    given ($SYNC)
    {
        when (/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        {
            $SYNC .= ':'.SYNC_PORT;
        }
        when (/\d{1,3}\.\d{1,3}/)
        {
            $SYNC = BASE_SYNC_IP.".$SYNC:".SYNC_PORT;
        }
        default
        {
            die "IP [$SYNC] does not look valid.";
        }
    }

    sync();
}
################################################################################
sub fetch_image
{
    my %args = @_;
    my $found = 0;
    my $card_name = $args{card_name};
    my $card_type = $args{card_type} || '';

    my $image_name = $args{image_name};
    unless ($image_name)
    {
        $image_name = lc($card_name);
        $image_name =~ s/\s+/_/g;
        $image_name =~ s/[',]//g;
        $image_name .= '.jpg';
    }

    my $response = $UA->get("http://magiccards.info/query?q=$card_name");
    die "[".$response->status_line()."] Request failed for '$card_name'"
        if $response->is_error();

    my $regex;
    my $img_url;
    given ($card_type)
    {
        when ('Scheme')
        {
            $img_url = "http://magiccards.info/extras/scheme/archenemy";
            $regex = qr|<img src="http://magiccards.info/extras/scheme/archenemy/(.*)\.jpg"\s+alt="([^"]+)"|;
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
        utf8::encode($name);

        if (lc ($name) eq lc($card_name))
        {
            $found = 1;
                
            # Fetch Image
            unless ($args{dry_run})
            {
                _msg("Fetching '$card_name' as '$image_name'...\n");

                my $response = $UA->get("$img_url/$img_path.jpg",
                    ':content_file' => $image_name);

                _err("[".$response->status_line()."] Failed to fetch image '$image_name'")
                    if $response->is_error();
            }

            last;
        }
    }

    _err("Card not found: [$card_name]\n") unless $found;
}
################################################################################
sub fetch_images_db
{
    my %args = @_;
    my $db = $args{db};
    my $dry_run = $args{dry_run} || 0;

    my $dbh = DBI->connect ("dbi:CSV:", {f_ext=>'csv'})
        or die "Cannot connect: $DBI::errstr";
    
    my $stmt = $dbh->prepare("select Name,Type,ImageName from $db");
    $stmt->execute();
    
    while (my $row = $stmt->fetchrow_hashref())
    {
        next if -f $row->{ImageName};
    
        _debug("--> $row->{Name} , $row->{ImageName} <--\n");
        fetch_image(
            card_name  => $row->{Name},
            card_type  => $row->{Type},
            image_name => $row->{ImageName},
            dry_run    => $dry_run
        );
    }
}
################################################################################
sub check_dups
{
    my %args = @_;
    my $db = $args{db};
    
    my $dbh = DBI->connect ("dbi:CSV:", {f_ext=>'csv'})
        or die "Cannot connect: $DBI::errstr";
    
    my $stmt = $dbh->prepare("select Name from $db");
    $stmt->execute();
    
    my %dups;
    while (my $row = $stmt->fetchrow_hashref())
    {
        $dups{lc($row->{Name})}++;
    }

    map
    {
        _err("Duplicate Card Found: [$_] ($dups{$_})\n")
            if $dups{$_} > 1;
    } keys %dups;
}
################################################################################
sub sync
{
    my %args = @_;

    sync_db() if $CMD eq 'fetch_images_db';
    sync_images();
}
################################################################################
sub sync_db
{
    my %args = @_;
    
    _msg("Syncing $NAME to HanDBase...\n");
    my $response = $UA->post(
        "http://$SYNC/applet_add.html",
        {
            localfile => [$NAME],
            appletname => "Magic Cards" #TODO: don't hard-code DB name
        },
        'Content_Type' => 'form-data'
    );

    _err("[".$response->status_line()."] Error uploading DB to HanDBase: $NAME")
        if $response->is_error();    
}
################################################################################
sub sync_images
{
    my %args = @_;

    my @files = read_dir('.');
    @files = sort @files;
    foreach my $image_name (@files)
    {
        next unless $image_name =~ /\.jpg$/;

        my @stats = stat $image_name;
        #9 == mtime
        if ($stats[9] > $START_TIME)
        {
            _msg("Syncing '$image_name' to HanDBase @ $SYNC...\n");
            my $response = $UA->post(
                "http://$SYNC/applet_add.html",
                {localfile => [$image_name]},
                'Content_Type' => 'form-data'
            );
            _err("[".$response->status_line()."] Error uploading image to HanDBase '$image_name'")
                if $response->is_error();
        }
    }
}
################################################################################
sub _msg
{
    my $msg = shift;

    $msg .= "\n" unless $msg =~ m|\n$|;
    print $msg unless $SILENT;
}
################################################################################
sub _debug
{
    my $msg = shift;

    $msg .= "\n" unless $msg =~ m|\n$|;
    print $msg if $DEBUG;
}
################################################################################
sub _err
{
    my $err = shift;

    $err .= "\n" unless $err=~ m|\n$|;
    print STDERR "ERR: $err";
}
################################################################################

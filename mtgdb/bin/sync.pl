#!/usr/bin/env perl
use strict;
use feature 'switch';

# use DBI;
# use File::Basename;
# use File::Slurp;
use LWP::UserAgent;

use constant IMAGE_DIR => "$ENV{MTGDB_CODEBASE}/images";
use constant BASE_SYNC_IP =>'192.168';
use constant SYNC_PORT    => 8080;

my $UA  = LWP::UserAgent->new();
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
sub _sync_db
{
    my $class = shift;
    my %args = @_;

    my $host = $args{host};
    my $file = $args{file};

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
##############################################################################
my $host = shift;
my $file = shift;

main->_sync_db(host => $host, file => $file);
##############################################################################

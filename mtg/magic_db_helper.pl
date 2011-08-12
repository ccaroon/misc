#!/nm/local/bin/perl
use strict;

use Data::Dumper;
use DBI;
use Getopt::Long;
use LWP::Simple;

my $INPUT;
my $SYNC;
GetOptions(
    "input=s" => \$INPUT,
    "sync"    => \$SYNC,
);
die "Usage: $0 --input <CSV File | Card Name> [--sync]" unless ($INPUT);
################################################################################
if ($INPUT =~ /\.csv$/)
{
    fetch_images_db(db => $INPUT);
}
else
{
    fetch_image(card_name => $INPUT);
}
################################################################################
sub fetch_image
{
    my %args = @_;
    my $found = 0;
    my $card_name = $args{card_name};

    my $image_name = $args{image_name};
    unless ($image_name)
    {
        $image_name = lc($card_name);
        $image_name =~ s/\s+/_/g;
        $image_name =~ s/[']//g;
        $image_name .= '.jpg';
    }

    my $html = get("http://magiccards.info/query?q=$card_name");
    die "Query failed! [$card_name]" unless $html;
    
    while ($html =~ s|<img src="http://magiccards.info/scans/(.*)\.jpg"\s+alt="([^"]+)"||)
    {
        my $img_path = $1;
        my $name = $2;

        if ($name eq $card_name)
        {
            # Fetch Image
            print STDERR "Fetching '$card_name' as '$image_name'...\n";
            getstore("http://magiccards.info/scans/$img_path.jpg", $image_name);

            if (-f $image_name)
            {
                $found = 1;

                # Upload to HandBase
                if ($SYNC)
                {
                    print STDERR "Syncing '$image_name' to HanDBase...\n";
                    system("curl -XPOST -F 'localfile=\@$image_name' http://192.168.2.95:8080/applet_add.html > /dev/null");
                }
            }
            else
            {
                print STDERR "=====> ERROR: Failed to fetch image '$image_name'.";
            }

            last;
        }
    }
    
    print STDERR "Card not found: [$card_name]\n" unless $found;
}
################################################################################
sub fetch_images_db
{
    my %args = @_;
    my $db = $args{db};
    
    my $dbh = DBI->connect ("dbi:CSV:", {f_ext=>'csv'})
        or die "Cannot connect: $DBI::errstr";
    
    my $stmt = $dbh->prepare("select Name,ImageName from $db");
    $stmt->execute();
    while (my $row = $stmt->fetchrow_hashref())
    {
        next if -f $row->{ImageName};
    
        print STDERR "--> $row->{Name} , $row->{ImageName} <--\n";
        fetch_image(card_name => $row->{Name}, image_name => $row->{ImageName});
    }
}
################################################################################

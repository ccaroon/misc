#!/nm/local/bin/perl
use strict;

use Data::Dumper;
use LWP::Simple;
use DBI;
################################################################################

my $dbh = DBI->connect ("dbi:CSV:", {f_ext=>'csv'}) or die "Cannot connect: $DBI::errstr";

my $stmt = $dbh->prepare("select Name,ImageName from magic_cards.csv");
$stmt->execute();
while (my $row = $stmt->fetchrow_hashref())
{
    next if -f $row->{ImageName};

    print STDERR "=====> magic.pl #30 --> $row->{Name} , $row->{ImageName}\n";
    
    my $html = get("http://magiccards.info/query?q=$row->{Name}");
    die "Query failed! [$row->{Name}]" unless $html;
    
    
    $html =~ m|<img src="http://magiccards.info/scans/(.*)\.jpg"|;
    my $img_path = $1;
    getstore("http://magiccards.info/scans/$img_path.jpg", $row->{ImageName});

    system("curl -XPOST -F 'localfile=\@$row->{ImageName}' http://192.168.2.95:8080/applet_add.html > /dev/null");
}

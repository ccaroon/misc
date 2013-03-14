#!/usr/bin/env perl
use Data::Dumper;
use File::Slurp;
use Date::Format;

my $db = shift;

die "No database name specified." unless defined $db;

my $out_file = "$db.html";
unlink $out_file if -f $out_file;

my $date = time2str("%b %d, %Y %R", time);

my $header =<<EOF;
<div align="center">
<h1>$db</h1>
<h2>$date</h2>
</div>
EOF

append_file($out_file, $header);

my $db_cmd = "mysql -h localhost -uroot $db";


my $str = `echo "show tables;" | $db_cmd`;

my @tables;
if (@ARGV > 0)
{
    @tables = @ARGV;
}
else
{
    @tables = split /\n/, $str;
    shift @tables;
}

foreach my $t (@tables)
{
    print STDERR "Working...$t\n";
    my $t_name = uc $t;
    my $html = `echo "describe $t;" | $db_cmd -H`;    

    my $data =<<EOF;
<table>
    <tr>
        <th bgcolor="#AAAAAA" colspan="99"><b>$t_name</b></th>
    </tr>
    <tr>
        <td>$html</td>
    </tr>
</table>
<br>
EOF
    append_file($out_file, $data);
}

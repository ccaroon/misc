#!/nm/local/bin/perl
################################################################################
# $Id: md_convert.pl 1697 2009-11-24 21:09:40Z ccaroon $
################################################################################
use strict;

use Cwd qw(abs_path);
use File::Basename;
use File::Slurp;
#use Text::Markdown;
use HTML::WikiConverter;
use HTML::WikiConverter::MediaWiki;
use Pod::HTML2Pod;

die "Usage: $0 <markdown.txt> <wiki|html|pod>" unless @ARGV == 2;

my $in_file = shift;
my $format  = shift;
my ($name, $path, undef) = fileparse($in_file, '.txt');
my $out_file = "$path$name";

#my $md_text = read_file($in_file);
#my $html    = Text::Markdown::markdown($md_text);
my $helper_path = dirname(abs_path $0);
my $html = `$helper_path/md_render.rb $in_file`;

my $output;
if ($format eq 'html')
{
    $output = $html;
}
elsif ($format eq 'wiki')
{
    my $wc  = HTML::WikiConverter->new(dialect => 'MediaWiki');
    $output = $wc->html2wiki(html => $html);
}
elsif ($format eq 'pod')
{
    $output = Pod::HTML2Pod::convert(content => $html);
}
else
{
    print STDERR "Unknown format: $format\n";
}

write_file("$out_file.$format", $output) if $output;

print STDERR "$in_file --> $out_file.$format\n";


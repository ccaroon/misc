#!/usr/bin/env perl
use strict;

# TODO: Rewrite as App::pherkin

use Getopt::Long;
my %opts;
my $opts = GetOptions(
    "tags=s@" => \$opts{tags},
    "help"    => \$opts{help},
);

use Test::BDD::Cucumber::Loader;
use Test::BDD::Cucumber::Harness::TermColor;
use Test::BDD::Cucumber::Model::TagSpec;

my $src = shift || './features/';

main->help() if $opts{help};
################################################################################
my ( $executor, @features ) = Test::BDD::Cucumber::Loader->load($src);
die "No feature files found: [$src]\n" unless @features;

my $tag_spec;
if ($opts{tags})
{
    my $tags = main->parse_tags($opts{tags});
    $tag_spec = Test::BDD::Cucumber::Model::TagSpec->new(tags => $tags);
}

my $harness  = Test::BDD::Cucumber::Harness::TermColor->new();
$executor->execute( $_, $harness, $tag_spec ) for @features;

my $result = $harness->result();
exit( $result->result eq 'failing' );
################################################################################
# TODO: only basic parsing, implement more feature complete parsing of tags
################################################################################
sub parse_tags
{
    my $class    = shift;
    my $raw_tags = shift;

    my @tags = @$raw_tags;
    
    foreach my $ts (@tags)
    {
        $ts =~ s/\s//g;
        if ($ts =~ /,/)
        {
            my @or = split /,/, $ts;
            unshift @or, 'or';
            $ts = \@or;
        }
    }

    unshift @tags, 'and';

    return (wantarray ? @tags : \@tags);    
}
################################################################################
sub help
{
    print <<'EOF';
Usage: cucumber.pl [options] [features_directory]

features_directory defaults to './features'

Options:
    --tags TAG_EXPRESSION

    Only execute the features or scenarios with tags matching TAG_EXPRESSION.
    Scenarios inherit tags declared on the Feature level. The simplest
    TAG_EXPRESSION is simply a tag. Example: --tags @dev. When a tag in a tag
    expression starts with a ~, this represents boolean NOT. Example: --tags ~@dev.
    A tag expression can have several tags separated by a comma, which represents
    logical OR. Example: --tags @dev,@wip. The --tags option can be specified
    several times, and this represents logical AND.

    Example: --tags @foo,~@bar --tags @zap.

    This represents the boolean expression (@foo || !@bar) && @zap.

    Beware that if you want to use several negative tags to exclude several tags
    you have to use logical AND: --tags ~@fixme --tags ~@buggy.
EOF

    exit;
}
################################################################################

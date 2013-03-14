#!/bin/env perl
################################################################################
package main;
use strict;

use Getopt::Long;
use YAML 'LoadFile';

use constant PROJECT => 'CR';

# TODO: Change to be your default crucible host
#       Can also be specified in .crucible_uploadrc
use constant HOST => 'crucible.example.com:8060';
################################################################################
# Main
################################################################################
my %opts;
GetOptions(
    "name=s"      => \$opts{name},
    "comment=s"   => \$opts{comment},
    "reviewer=s@" => \$opts{reviewers},
    "file=s@"     => \$opts{files},
    "id=s"        => \$opts{id},
    "project=s"   => \$opts{project},
    "username=s"  => \$opts{username},
    "password=s"  => \$opts{password},
    "debug"       => \$opts{debug},
    "help"        => \$opts{help}
);
$opts{id} = uc $opts{id};

usage() if $opts{help};

merge_config( opts => \%opts );

my $review = CrucibleReview->new(%opts);
$review->build();
$review->save();
################################################################################
# Merge command line options with settings in RC file.
# Command line options override RC file settings.
################################################################################
sub merge_config {
    my %args = @_;

    my $cmd_opts = $args{opts};

    my $rc_file = $ENV{HOME} . "/.crucible_uploadrc";
    my $config  = {};
    if ( -f $rc_file ) {
        $config = LoadFile($rc_file);
    }

    foreach my $key ( keys %{$config} ) {
        $cmd_opts->{$key} //= $config->{$key};
    }

    # Prompt for required options if missing
    $cmd_opts->{username} ||= prompt("Username:");
    $cmd_opts->{password} ||= prompt("Password:");
    $cmd_opts->{name}     ||= prompt("Review Name:") unless $cmd_opts->{id};

    # Set host and project defaults if necessary
    $cmd_opts->{host}    ||= HOST;
    $cmd_opts->{project} ||= PROJECT;
}
################################################################################
sub prompt {
    my $msg = shift;

    print "$msg ";
    my $value = <STDIN>;
    chomp $value;

    return ($value);
}
################################################################################
sub usage {
    print STDERR <<EOF;
Options:
    * --name:     Review name
    * --username: Crucible username
    * --password: Crucible password
    * --id:       Review ID. Used for uploading additional patches to an
                  existing review.
    * --comment:  Add a general comment to the review
    * --project:  Crucible Project Key
    * --reviewer: Crucible username of someone you would like to review your code.
                  Can be used multiple times.
    * --file:     Specify which file(s) to include in upload.
                  Can be used multiple times.
    * --debug:    Prints some debugging info.
    * --help:     This message.

Config file: $ENV{HOME}/.crucible_uploadrc
Almost any command line option can have a default value in the config file.

    ---
    host: 'Domain Name of Crucible Server'
    project: 'Your Default Crucible Project'
    username: 'Your Crucible username'
    password: 'Your Crucible password'
    reviewers:
        - 'My Favorite Reviewer #1'
        - 'My Favorite Reviewer #2'

Examples:

1. Create a new review:
    $0 --name "STUFF-1234 - Fixed that annoying bug" --reviewer jdoe
2. Add a patch to an existing review:
    $0 --id CR-17 --file only/upload/this/File.pm
EOF
    exit(0);
}
################################################################################
################################################################################
package CrucibleReview;

use feature 'state';

use File::Basename;
use HTTP::Request;
use JSON::XS;
use LWP::UserAgent;

use constant REVIEW_RESOURCE_PATH => '/rest-service/reviews-v1';
################################################################################
sub new {
    my $class = shift;
    my %args  = @_;

    my $this = \%args;
    bless $this, $class;

    $this->{ua} = LWP::UserAgent->new();

    # Get repository information
    $this->_repository_info();

    return ($this);
}
################################################################################
sub build {
    my $this = shift;

    my $name = $this->{name} unless $this->{id};
    my $patch = $this->_create_patch();

    if ($patch) {
        $this->_build_review_data( name => $name, patch => $patch );
        $this->_build_reviewer_data();
    }
    else {
        die "No changes found!\n";
    }
}
################################################################################
sub save {
    my $this = shift;

    my $path = REVIEW_RESOURCE_PATH;
    if ( $this->{id} ) {
        $path .= "/$this->{id}/patch";
    }

    # POST #1 - Create or Update Review
    my $response = $this->_crucible_post(
        path => $path,
        data => $this->{review_data}
    );

    my $data = $this->_decode_json( json => $response->content() );

    my $base_url = 'http://' . $this->{host};
    my $review   = {
        is_success => $response->is_success(),
        rest_url   => $base_url
            . REVIEW_RESOURCE_PATH
            . "/$data->{permaId}->{id}",
        url  => $base_url . "/cru/" . $data->{permaId}->{id},
        data => $data
    };

    if ( $review->{is_success} ) {
        print "Success: $review->{url}\n";

        # POST #2 -- Add Reviewers
        if ( $this->{reviewers} ) {
            my $response = $this->_crucible_post(
                path => "$review->{rest_url}/reviewers",
                data => $this->{reviewers_data}
            );

            $data =
                ( $response->content() )
                ? $this->_decode_json( json => $response->content() )
                : {};

            if ( $response->is_success() ) {
                print STDERR "Added Reviewers: "
                    . ( join ',', @{ $this->{reviewers} } ) . "\n";
            }
            else {
                print STDERR "Failed to add reviewers: "
                    . $data->{message} . "\n";
            }
        }

        # POST #3 -- Add a Comment
        if ( $this->{comment} ) {
            my $response = $this->_crucible_post(
                path => "$review->{rest_url}/comments",
                data => { message => $this->{comment} }
            );

            unless ( $response->is_success() ) {
                $data = $this->_decode_json( json => $response->content() );
                print STDERR "Failed to add comment: "
                    . $data->{message} . "\n";
            }
        }
    }
    else {
        die "Review post failed: " . $review->{data}->{message};
    }
}
################################################################################
sub _crucible_post {
    my $this = shift;
    my %args = @_;
    my $path = $args{path};

    my $url =
        ( $path =~ m|^http://| )
        ? $path
        : "http://" . $this->{host} . $path;
    my $json = ( ref $args{data} ) ? encode_json( $args{data} ) : $args{data};

    my $req = HTTP::Request->new( POST => $url );
    $req->content($json);
    $req->header( 'Content-type' => 'application/json' );
    $req->header( 'Accept'       => 'application/json' );
    $req->headers()
        ->authorization_basic( $this->{username}, $this->{password} );

    if ( $this->{debug} ) {
        print STDERR <<EOF;
POST => $url
-------------------------------
$json
EOF
    }

    my $res = $this->{ua}->request($req);

    return ($res);
}
################################################################################
sub _build_review_data {
    my $this = shift;
    my %args = @_;

    my $data = {};
    unless ( $this->{id} ) {

        # Creating a new review
        $data = {
            reviewData => {
                projectKey           => $this->{project},
                name                 => $args{name},
                description          => "N/A",
                author               => { userName => $this->{username} },
                type                 => "REVIEW",
                state                => "Review",
                allowReviewersToJoin => 'true'
            }
        };
    }

    # Add patch and anchor info
    $data->{patch}  = $args{patch};
    $data->{anchor} = {
        stripCount       => 0,
        anchorPath       => $this->{repo_info}->{path},
        anchorRepository => $this->{repo_info}->{name}
    };

    $this->{review_data} = $data;
}
################################################################################
sub _build_reviewer_data {
    my $this = shift;

    my $data = undef;
    if ( $this->{reviewers} ) {
        $data = join ',', @{ $this->{reviewers} };
    }

    $this->{reviewers_data} = $data;
}
################################################################################
sub _is_svn {
    my $this = shift;

    state $is_svn = undef;

    unless ( defined $is_svn ) {
        $is_svn = 0;
        $is_svn = 1 if -d "./.svn";
    }

    return ($is_svn);
}
################################################################################
sub _is_git {
    my $this = shift;

    state $is_git = undef;

    unless ( defined $is_git ) {
        $is_git = 0;

        my $out = `git status 2>&1`;
        $is_git = ( $out =~ /fatal: Not a git repository/ ) ? 0 : 1;
    }

    return ($is_git);
}
################################################################################
# NOTE: Works with SVN and GIT SVN bridge. Will NOT work with "regular" git.
################################################################################
sub _repository_info {
    my $this = shift;

    my $info;
    if ( $this->_is_svn() ) {
        $info = `svn info`;
    }
    elsif ( $this->_is_git() ) {
        $info = `git svn info`;
    }
    else {
        die "Cannot determine Source Control Management tool.\n";
    }

    my %data;
    foreach my $line ( split /\n/, $info ) {
        my ( $key, $val ) = split /:\s*/, $line, 2;
        $key =~ s/\s+/_/;
        $key = lc $key;
        $data{$key} = $val;
    }

    my $path = $data{url};
    my $root = $data{repository_root};
    $root =~ s/\+/\\+/;
    $path =~ s|$root/trunk/?||;
    $data{path} = $path;
    $data{name} = basename( $data{repository_root} );

    $this->{repo_info} = \%data;
}
################################################################################
sub _create_patch {
    my $this = shift;

    my $file_list = '';
    if ( $this->{files} ) {
        $file_list = join ' ', @{ $this->{files} };
    }

    my $patch;
    if ( $this->_is_svn() ) {
        $patch = `svn diff $file_list`;
    }
    elsif ( $this->_is_git() ) {

        # -U100 --> 100 lines of context
        $patch = `git diff -U100 $file_list`;
    }
    else {
        die "Could not create patch file: unknown SCM.\n";
    }

    return ($patch);
}
################################################################################
sub _decode_json {
    my $this = shift;
    my %args = @_;

    my $data = undef;
    eval { $data = decode_json( $args{json} ); };
    if ($@) {
        print STDERR "Expected JSON content. Got this instead...\n";
        die $args{json};
    }

    return ($data);
}
################################################################################

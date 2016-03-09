#!/usr/bin/perl
################################################################################
use strict;
use File::Slurp;

my @types = qw(plain leet t-remover num hex clean);
die "$0 <path> <ext> [".(join '|', @types)."|rand]\n" unless @ARGV >= 2;

my $path = $ARGV[0];
my $ext  = $ARGV[1];
my $type = $ARGV[2] || 'plain';
################################################################################
my @files = read_files($path);
my @files = randomize_list(@files);
# print STDERR "=====> Num files [".scalar(@files)."] \n";
# TODO: randomize file list
for my $file (@files)
{
    next unless defined $ext and $file =~ /$ext$/;

    my $orig_type = $type;
    # print "*** $file ***\n\n";
    open (IN, "<$file");
    while (<IN>)
    {
        if ($type eq "rand") {
            $type = $types[int rand @types]
        }
        
        if ($type eq "leet") {
            s/e/3/ig;
            s/i/!/ig;
            s/a/@/ig;
            s/o/0/ig;
            s/s/\$/ig;
            s/t/7/ig;
        } 
        elsif ($type eq "t-remover") {
            s/t//ig;
        }
        elsif ($type eq "num") {
            s/([A-Za-z])/ord($1)/eg;
        }
        elsif ($type eq "hex") {
            s/(.)/sprintf("0x%x", ord($1))/eg;
            s/\s+/' ' x int rand 15/eg;
            chomp;
        }
        elsif ($type eq "clean") {
            s/[^A-Za-z0-9\s]/ /g;
            s/ +/ /g;
        }

        print;
        $type = $orig_type;
    }
    close IN;
}
################################################################################
sub read_files {
    my $path = shift;
    my @files;

    # print STDERR "=====> Reading $path \n";
    my @contents = read_dir($path);
    for my $item (@contents) {
        if (-d "$path/$item") {
            push @files, read_files("$path/$item");
        }
        elsif ($item =~ /$ext$/) {
            push @files, "$path/$item";
        }
    }

    return @files;
}
################################################################################
sub randomize_list {
    my @list = @_;
    my @new_list;
    
    while (@list > 0) {
        my $index = int rand @list;
        push @new_list, $list[$index];
        splice @list,$index,1;
    }

    return @new_list;
}

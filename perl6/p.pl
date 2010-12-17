#!/usr/bin/env perl6
################################################################################

use Person;

my $dad = Person.new(name => "Craig", age => 39);
my $mom = Person.new(name => "Cate", age => 38);
my $son = Person.new(name => "Nathan", age => 11);


my @family = ($dad,$mom,$son);

my $total_age = [+] @family>>.age();
say "Total Age: $total_age";

say "Oldest: {[max]@family>>.age()}";

#say time;

my $now = Date.new(1);
say $now;

my $d = Date.new('1971-02-19');
say $d;

#say "diff: {$now - $d}";
#!/usr/bin/env perl6

use v6;

sub order_shrimps($count, $from)
{
   say "I'd like $count pieces of shrimp from the $from, please.";
}


order_shrimps(7, "Havelock");

my %prefs = (from => 'Northern Sea');
order_shrimps(3, |%prefs);

order_shrimps(count => 15, from => 'Oriental');

order_shrimps(:count<23>, :from<Anywhere>);

order_shrimps(:count(34), :from('Virginia'));

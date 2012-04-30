#!/usr/bin/env ruby

input = ARGV[0];

input =~ /(\d+)([+\/])(\d+)/;

n1 = $1;
op = $2;
n2 = $3;

result = nil;
if (op == '+')
   result = n1.to_i+n2.to_i; 
elsif (op == '/')
    throw 'ZeroDivisionError' if n2.to_f == 0.0;
   result = n1.to_f/n2.to_f; 
end

puts result;

#!/usr/bin/env ruby

input = ARGV[0];
throw "Missing Input" if input.to_s.empty?

input =~ /(\d+)([+\/])(\d+)/;

n1 = $1;
op = $2;
n2 = $3;

result = nil;
if (op == '+')
   result = n1.to_i+n2.to_i; 
elsif (op == '/')
   if (n2.to_f == 0.0)
       result = 'Error - Division by Zero!';
   else
       result = n1.to_f/n2.to_f; 
   end
end

puts result;

#!/usr/bin/ruby

require 'rubygems';
require 'bluecloth';

file = File.new(ARGV[0]);
markdown = file.read();
html = BlueCloth.new(markdown).to_html;

puts html;
#out = File.open("#{ARGV[0]}.html","w");
#out.write(html);

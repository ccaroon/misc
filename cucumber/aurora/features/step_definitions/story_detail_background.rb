require 'watir-webdriver';

Given /^I am on an Aurora web site in:$/ do |table|
  @browsers = Array.new;
  table.raw.each do |col|
    b = Watir::Browser.new col[0].to_sym
    b.goto col[1].to_s;
    @browsers.push(b);
  end

end

And /^I navigate to a story detail page$/ do
  @browsers.each do |b|
    b.div(:id => 'content').link(:index => 0).click;
  end
end


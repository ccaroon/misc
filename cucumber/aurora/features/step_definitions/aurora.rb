require 'watir-webdriver';

Given /^I am on an Aurora web site in:$/ do |table|
  @browsers = Array.new;
  table.raw.each do |col|
    b = Watir::Browser.new col[0].to_sym
    b.goto "http://ccaroon-red-site.apps.nandomedia.com";
    @browsers.push(b);
  end

end

When /^I navigate to a story detail page$/ do
  @browsers.each do |b|
    b.div(:id => 'content').link(:index => 0).click;
  end
end

Then /^the Facebook Like button should be displayed$/ do
  @browsers.each do |b|
    button = b.div(:id => 'fb_iframe_container').frame(:id => 'fbLikeIframe');
    button.should exist;
    
    url = b.url;
    button.src.should =~ /#{url}/;    
  end
end

require 'watir-webdriver';

When /^I click on the section name in the breadcrumb$/ do
  @browsers.each do |b|
    l = b.ul(:id => "breadcrumb").li(:class => "current").link(:index => 0)
    @breadcrumb_url = l.href;
    l.click
  end
end

Then /^the corresponding section front page should display$/ do
  @browsers.each do |b|
    b.url.should =~ /#{@breadcrumb_url}\/?/;
  end
end

When /^I click on the comment count in the breadcrumb bar$/ do
  @browsers.each do |b|
    b.link(:id => "commentCount").click
  end
end

Then /^I am taken to the Disqus commenting on the story detail page$/ do
  @browsers.each do |b|
    b.url.should =~ /#disqus_thread$/
  end
end

Then /^the breadcrumb should be below the NavBar$/ do
  pending "watir-webdriver does not support :after? or :before?"
end

Then /^it should be above the Story headline$/ do
  pending "watir-webdriver does not support :after? or :before?"
end






